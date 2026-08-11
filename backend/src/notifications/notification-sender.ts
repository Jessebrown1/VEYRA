import { Injectable, Logger } from '@nestjs/common';

/** Phase-1 implementation: logs only (the notification's content is already persisted
 * as a SentNotification row by the caller, visible via GET /notifications/sent). Swap
 * this for a real APNs/FCM sender once push credentials exist — nothing else in the
 * codebase needs to change, this is the one interface call sites depend on. */
@Injectable()
export class NotificationSender {
  private readonly logger = new Logger('NotificationSender');

  async send(userId: string, message: string): Promise<void> {
    this.logger.log(`[DEV NOTIFICATION] user=${userId}: ${message}`);
  }
}
