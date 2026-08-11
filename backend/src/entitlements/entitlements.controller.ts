import { Controller, Get } from '@nestjs/common';
import { CurrentUser, type AuthenticatedUser } from '../common/decorators/current-user.decorator';
import { PLUS_ONLY_FEATURES } from './entitlements.config';
import { EntitlementsService } from './entitlements.service';

@Controller('entitlements')
export class EntitlementsController {
  constructor(private readonly entitlementsService: EntitlementsService) {}

  @Get()
  async get(@CurrentUser() user: AuthenticatedUser) {
    const isPlus = await this.entitlementsService.isPlus(user.userId);
    const memoryLimit = await this.entitlementsService.memoryLimit(user.userId);
    const features: Record<string, boolean> = {};
    for (const feature of PLUS_ONLY_FEATURES) {
      features[feature] = isPlus;
    }
    return { isPlus, memoryLimit, features };
  }
}
