import { Module } from '@nestjs/common';
import { NotificationSender } from './notification-sender';
import { NotificationsController } from './notifications.controller';
import { NotificationsService } from './notifications.service';

@Module({
  controllers: [NotificationsController],
  providers: [NotificationsService, NotificationSender],
})
export class NotificationsModule {}
