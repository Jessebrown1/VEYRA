import { Module } from '@nestjs/common';
import { CompanionsModule } from '../companions/companions.module';
import { AvatarController } from './avatar.controller';
import { AvatarService } from './avatar.service';

@Module({
  imports: [CompanionsModule],
  controllers: [AvatarController],
  providers: [AvatarService],
})
export class AvatarModule {}
