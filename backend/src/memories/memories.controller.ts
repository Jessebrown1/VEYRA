import { Body, Controller, Delete, Get, Param, Patch, Post } from '@nestjs/common';
import { CurrentUser, type AuthenticatedUser } from '../common/decorators/current-user.decorator';
import { UpdateMemoryDto } from './dto/update-memory.dto';
import { MemoriesService } from './memories.service';

@Controller()
export class MemoriesController {
  constructor(private readonly memoriesService: MemoriesService) {}

  @Get('companions/:id/memories')
  list(@CurrentUser() user: AuthenticatedUser, @Param('id') companionId: string) {
    return this.memoriesService.listForCompanion(user.userId, companionId);
  }

  @Patch('memories/:id')
  update(@CurrentUser() user: AuthenticatedUser, @Param('id') id: string, @Body() dto: UpdateMemoryDto) {
    return this.memoriesService.update(user.userId, id, dto.content);
  }

  @Delete('memories/:id')
  remove(@CurrentUser() user: AuthenticatedUser, @Param('id') id: string) {
    return this.memoriesService.deactivate(user.userId, id);
  }

  @Post('companions/:id/memories/clear')
  clearAll(@CurrentUser() user: AuthenticatedUser, @Param('id') companionId: string) {
    return this.memoriesService.clearAllForCompanion(user.userId, companionId);
  }
}
