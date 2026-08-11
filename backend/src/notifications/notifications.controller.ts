import { Body, Controller, Get, Patch } from '@nestjs/common';
import { CurrentUser, type AuthenticatedUser } from '../common/decorators/current-user.decorator';
import { UpdateNotificationSettingsDto } from './dto/update-notification-settings.dto';
import { NotificationsService } from './notifications.service';

@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get('settings')
  getSettings(@CurrentUser() user: AuthenticatedUser) {
    return this.notificationsService.getSettings(user.userId);
  }

  @Patch('settings')
  updateSettings(@CurrentUser() user: AuthenticatedUser, @Body() dto: UpdateNotificationSettingsDto) {
    return this.notificationsService.updateSettings(user.userId, dto);
  }

  /** Dev visibility into what the notification engine has generated — Phase 1 has no
   * real push delivery yet, so this is how you confirm it's working end-to-end. */
  @Get('sent')
  listSent(@CurrentUser() user: AuthenticatedUser) {
    return this.notificationsService.listSentForUser(user.userId);
  }
}
