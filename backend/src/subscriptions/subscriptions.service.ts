import { Injectable } from '@nestjs/common';
import { SubscriptionStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class SubscriptionsService {
  constructor(private readonly prisma: PrismaService) {}

  async get(userId: string) {
    const sub = await this.prisma.subscription.upsert({
      where: { userId },
      update: {},
      create: { userId },
    });
    return sub;
  }

  /** Dev-only: flips subscription status without a real store integration.
   * Real StoreKit / Play Billing verification is a Phase 2 item — this is the swap point. */
  async mockSet(userId: string, status: SubscriptionStatus) {
    return this.prisma.subscription.upsert({
      where: { userId },
      update: { status, provider: 'mock' },
      create: { userId, status, provider: 'mock' },
    });
  }
}
