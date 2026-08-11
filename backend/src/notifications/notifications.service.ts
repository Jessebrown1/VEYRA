import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { Companion, NotificationSettings } from '@prisma/client';
import { AiClientService } from '../ai/ai-client.service';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateNotificationSettingsDto } from './dto/update-notification-settings.dto';
import { NotificationSender } from './notification-sender';

// These would come from per-user "frequency" tuning in a later pass — kept as simple
// constants for Phase 1 rather than inventing unapproved schema.
const INACTIVITY_THRESHOLD_MS = 1000 * 60 * 60 * 24;
const COOLDOWN_MS = 1000 * 60 * 60 * 12;

type CompanionWithUser = Companion & {
  user: { timezone: string; notificationSettings: NotificationSettings | null };
};

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger('NotificationsService');

  constructor(
    private readonly prisma: PrismaService,
    private readonly ai: AiClientService,
    private readonly sender: NotificationSender,
  ) {}

  async getSettings(userId: string) {
    return this.prisma.notificationSettings.upsert({
      where: { userId },
      update: {},
      create: { userId },
    });
  }

  async updateSettings(userId: string, dto: UpdateNotificationSettingsDto) {
    return this.prisma.notificationSettings.upsert({
      where: { userId },
      update: dto,
      create: { userId, ...dto },
    });
  }

  async listSentForUser(userId: string) {
    return this.prisma.sentNotification.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: 20,
    });
  }

  private isWithinQuietHours(quietStart: string, quietEnd: string, localMinutes: number): boolean {
    const [sh, sm] = quietStart.split(':').map(Number);
    const [eh, em] = quietEnd.split(':').map(Number);
    const start = sh * 60 + sm;
    const end = eh * 60 + em;
    if (start === end) return false;
    if (start < end) return localMinutes >= start && localMinutes < end;
    return localMinutes >= start || localMinutes < end;
  }

  private localMinutesFor(timezone: string): number {
    try {
      const formatted = new Intl.DateTimeFormat('en-GB', {
        hour: 'numeric',
        minute: 'numeric',
        hour12: false,
        timeZone: timezone,
      }).format(new Date());
      const [h, m] = formatted.split(':').map(Number);
      return (h % 24) * 60 + m;
    } catch {
      const now = new Date();
      return now.getUTCHours() * 60 + now.getUTCMinutes();
    }
  }

  @Cron('*/15 * * * *')
  async scanAndNotify() {
    const companions = (await this.prisma.companion.findMany({
      include: { user: { include: { notificationSettings: true } } },
    })) as CompanionWithUser[];

    for (const companion of companions) {
      try {
        await this.maybeNotify(companion);
      } catch (err) {
        this.logger.warn(`Notification scan failed for companion ${companion.id}: ${(err as Error).message}`);
      }
    }
  }

  private async maybeNotify(companion: CompanionWithUser) {
    const settings = companion.user.notificationSettings;
    if (!settings || !settings.enabled) return;

    const recentSend = await this.prisma.sentNotification.findFirst({
      where: { userId: companion.userId, companionId: companion.id },
      orderBy: { createdAt: 'desc' },
    });
    if (recentSend && Date.now() - recentSend.createdAt.getTime() < COOLDOWN_MS) return;

    const localMinutes = this.localMinutesFor(companion.user.timezone);
    if (settings.quietHoursEnabled && settings.quietStart && settings.quietEnd) {
      const inQuiet = this.isWithinQuietHours(settings.quietStart, settings.quietEnd, localMinutes);
      if (inQuiet) {
        if (settings.sleepReminders) await this.send(companion, 'sleep');
        return; // respect quiet hours either way
      }
    }

    if (!settings.companionCheckins) return;
    const lastInteraction = companion.lastInteractionAt ?? companion.createdAt;
    if (Date.now() - lastInteraction.getTime() < INACTIVITY_THRESHOLD_MS) return;

    await this.send(companion, 'inactivity');
  }

  private async send(companion: Companion, reason: 'inactivity' | 'sleep') {
    const { message } = await this.ai.generateNotification({
      companion_name: companion.name,
      personality_traits: companion.personalityTraits as Record<string, number>,
      relationship_id: companion.relationshipId,
      user_preferred_name: companion.preferredUserName,
      reason,
    });

    await this.prisma.sentNotification.create({
      data: { userId: companion.userId, companionId: companion.id, type: reason, content: message },
    });

    await this.sender.send(companion.userId, message);
  }
}
