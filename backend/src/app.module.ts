import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { ScheduleModule } from '@nestjs/schedule';
import { AiClientModule } from './ai/ai-client.module';
import { AuthModule } from './auth/auth.module';
import { AvatarModule } from './avatar/avatar.module';
import { JwtAuthGuard } from './common/guards/jwt-auth.guard';
import { CompanionsModule } from './companions/companions.module';
import { ConversationsModule } from './conversations/conversations.module';
import { EntitlementsModule } from './entitlements/entitlements.module';
import { HealthController } from './health.controller';
import { LocationModule } from './location/location.module';
import { MemoriesModule } from './memories/memories.module';
import { NotificationsModule } from './notifications/notifications.module';
import { PrismaModule } from './prisma/prisma.module';
import { SubscriptionsModule } from './subscriptions/subscriptions.module';
import { UsersModule } from './users/users.module';
import { WallpapersModule } from './wallpapers/wallpapers.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    ScheduleModule.forRoot(),
    PrismaModule,
    AiClientModule,
    EntitlementsModule,
    AuthModule,
    UsersModule,
    CompanionsModule,
    ConversationsModule,
    MemoriesModule,
    WallpapersModule,
    AvatarModule,
    SubscriptionsModule,
    NotificationsModule,
    LocationModule,
  ],
  controllers: [HealthController],
  providers: [
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
  ],
})
export class AppModule {}
