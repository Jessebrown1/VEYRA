import { Body, Controller, Get, Post } from '@nestjs/common';
import { CurrentUser, type AuthenticatedUser } from '../common/decorators/current-user.decorator';
import { MockSetDto } from './dto/mock-set.dto';
import { SubscriptionsService } from './subscriptions.service';

@Controller('subscription')
export class SubscriptionsController {
  constructor(private readonly subscriptionsService: SubscriptionsService) {}

  @Get()
  get(@CurrentUser() user: AuthenticatedUser) {
    return this.subscriptionsService.get(user.userId);
  }

  /** Dev-only endpoint to exercise entitlement-gated UI without a real store. */
  @Post('mock-set')
  mockSet(@CurrentUser() user: AuthenticatedUser, @Body() dto: MockSetDto) {
    return this.subscriptionsService.mockSet(user.userId, dto.status);
  }
}
