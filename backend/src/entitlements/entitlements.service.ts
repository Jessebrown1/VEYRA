import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Feature, FREE_MEMORY_LIMIT, PLUS_MEMORY_LIMIT, PLUS_ONLY_FEATURES } from './entitlements.config';

@Injectable()
export class EntitlementsService {
  constructor(private readonly prisma: PrismaService) {}

  async isPlus(userId: string): Promise<boolean> {
    const sub = await this.prisma.subscription.findUnique({ where: { userId } });
    if (!sub) return false;
    if (sub.status === 'active') return true;
    if (sub.status === 'trial' && (!sub.expiresAt || sub.expiresAt > new Date())) return true;
    return false;
  }

  async canUse(userId: string, feature: Feature): Promise<boolean> {
    if (!PLUS_ONLY_FEATURES.includes(feature)) return true;
    return this.isPlus(userId);
  }

  async memoryLimit(userId: string): Promise<number> {
    return (await this.isPlus(userId)) ? PLUS_MEMORY_LIMIT : FREE_MEMORY_LIMIT;
  }
}
