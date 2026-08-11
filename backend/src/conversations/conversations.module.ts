import { Module } from '@nestjs/common';
import { CompanionsModule } from '../companions/companions.module';
import { MemoriesModule } from '../memories/memories.module';
import { ConversationsController } from './conversations.controller';
import { ConversationsService } from './conversations.service';

@Module({
  imports: [CompanionsModule, MemoriesModule],
  controllers: [ConversationsController],
  providers: [ConversationsService],
})
export class ConversationsModule {}
