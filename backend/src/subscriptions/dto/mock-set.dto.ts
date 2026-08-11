import { IsIn } from 'class-validator';
import { SubscriptionStatus } from '@prisma/client';

export class MockSetDto {
  @IsIn(['inactive', 'active', 'trial', 'expired'])
  status: SubscriptionStatus;
}
