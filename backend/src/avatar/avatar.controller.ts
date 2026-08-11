import { Body, Controller, Get, Param, Patch } from '@nestjs/common';
import { AvatarAssetCategory } from '@prisma/client';
import { CurrentUser, type AuthenticatedUser } from '../common/decorators/current-user.decorator';
import { AvatarService } from './avatar.service';
import { UpdateAvatarDto } from './dto/update-avatar.dto';

@Controller()
export class AvatarController {
  constructor(private readonly avatarService: AvatarService) {}

  @Get('avatar/assets')
  listAll() {
    return this.avatarService.listAssets();
  }

  @Get('avatar/assets/:category')
  listByCategory(@Param('category') category: AvatarAssetCategory) {
    return this.avatarService.listAssets(category);
  }

  @Patch('companions/:id/avatar')
  update(@CurrentUser() user: AuthenticatedUser, @Param('id') id: string, @Body() dto: UpdateAvatarDto) {
    return this.avatarService.updateAvatar(user.userId, id, dto);
  }
}
