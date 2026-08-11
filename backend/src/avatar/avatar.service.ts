import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { AvatarAssetCategory } from '@prisma/client';
import { CompanionsService } from '../companions/companions.service';
import { EntitlementsService } from '../entitlements/entitlements.service';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateAvatarDto } from './dto/update-avatar.dto';

@Injectable()
export class AvatarService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly entitlements: EntitlementsService,
    private readonly companions: CompanionsService,
  ) {}

  async listAssets(category?: AvatarAssetCategory) {
    return this.prisma.avatarAsset.findMany({
      where: { isActive: true, ...(category ? { category } : {}) },
      orderBy: [{ category: 'asc' }, { name: 'asc' }],
    });
  }

  async updateAvatar(userId: string, companionId: string, dto: UpdateAvatarDto) {
    await this.companions.getOwned(userId, companionId);

    const assetIds = [dto.skinAssetId, dto.hairAssetId, dto.eyeAssetId, dto.outfitAssetId, dto.accessoryAssetId].filter(
      (id): id is string => !!id,
    );

    if (assetIds.length > 0) {
      const assets = await this.prisma.avatarAsset.findMany({ where: { id: { in: assetIds } } });
      const isPlus = await this.entitlements.isPlus(userId);
      for (const id of assetIds) {
        const asset = assets.find((a) => a.id === id);
        if (!asset) {
          throw new NotFoundException({ code: 'ASSET_NOT_FOUND', message: `Avatar asset not found: ${id}` });
        }
        if (asset.isPremium && !isPlus) {
          throw new ForbiddenException({ code: 'PREMIUM_REQUIRED', message: `"${asset.name}" requires VEYRA+.` });
        }
      }
    }

    const data = {
      skinAssetId: dto.skinAssetId,
      hairAssetId: dto.hairAssetId,
      eyeAssetId: dto.eyeAssetId,
      outfitAssetId: dto.outfitAssetId,
      accessoryAssetId: dto.accessoryAssetId,
    };

    return this.prisma.avatarConfig.upsert({
      where: { companionId },
      update: data,
      create: { companionId, ...data },
    });
  }
}
