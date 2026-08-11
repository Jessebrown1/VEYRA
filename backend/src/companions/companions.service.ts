import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { EntitlementsService } from '../entitlements/entitlements.service';
import { PrismaService } from '../prisma/prisma.service';
import {
  isPersonalityPremium,
  isRelationshipPremium,
  isTermPremium,
  personalityExists,
  relationshipExists,
} from './catalog';
import { CreateCompanionDto } from './dto/create-companion.dto';
import { UpdateCompanionDto } from './dto/update-companion.dto';

@Injectable()
export class CompanionsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly entitlements: EntitlementsService,
  ) {}

  private async assertCanUsePersonality(userId: string, traits: Record<string, number>) {
    const isPlus = await this.entitlements.isPlus(userId);
    for (const traitId of Object.keys(traits)) {
      if (!personalityExists(traitId)) {
        throw new ForbiddenException({
          code: 'INVALID_PERSONALITY',
          message: `Unknown personality trait: ${traitId}`,
        });
      }
      if (!isPlus && isPersonalityPremium(traitId)) {
        throw new ForbiddenException({
          code: 'PREMIUM_REQUIRED',
          message: `The "${traitId}" personality trait requires VEYRA+.`,
        });
      }
    }
  }

  private async assertCanUseRelationship(userId: string, relationshipId: string) {
    if (!relationshipExists(relationshipId)) {
      throw new ForbiddenException({
        code: 'INVALID_RELATIONSHIP',
        message: `Unknown relationship: ${relationshipId}`,
      });
    }
    if (isRelationshipPremium(relationshipId) && !(await this.entitlements.isPlus(userId))) {
      throw new ForbiddenException({
        code: 'PREMIUM_REQUIRED',
        message: `The "${relationshipId}" relationship requires VEYRA+.`,
      });
    }
  }

  private async assertCanUseTerm(userId: string, relationshipId: string, termId: string) {
    if (isTermPremium(relationshipId, termId) && !(await this.entitlements.isPlus(userId))) {
      throw new ForbiddenException({
        code: 'PREMIUM_REQUIRED',
        message: 'That term of address requires VEYRA+.',
      });
    }
  }

  async create(userId: string, dto: CreateCompanionDto) {
    await this.assertCanUseRelationship(userId, dto.relationshipId);
    await this.assertCanUsePersonality(userId, dto.personalityTraits);
    await this.assertCanUseTerm(userId, dto.relationshipId, dto.preferredTermId);

    return this.prisma.companion.create({
      data: {
        userId,
        name: dto.name,
        relationshipId: dto.relationshipId,
        personalityTraits: dto.personalityTraits as Prisma.InputJsonValue,
        preferredUserName: dto.preferredUserName,
        preferredTermId: dto.preferredTermId,
        wallpaperId: dto.wallpaperId,
        avatarConfig: { create: {} },
      },
      include: { avatarConfig: true },
    });
  }

  async listForUser(userId: string) {
    return this.prisma.companion.findMany({
      where: { userId },
      include: { avatarConfig: true },
      orderBy: { createdAt: 'asc' },
    });
  }

  async getOwned(userId: string, companionId: string) {
    const companion = await this.prisma.companion.findUnique({
      where: { id: companionId },
      include: { avatarConfig: true },
    });
    if (!companion) {
      throw new NotFoundException({ code: 'COMPANION_NOT_FOUND', message: 'Companion not found.' });
    }
    if (companion.userId !== userId) {
      throw new ForbiddenException({
        code: 'NOT_YOUR_COMPANION',
        message: 'You do not have access to this companion.',
      });
    }
    return companion;
  }

  async update(userId: string, companionId: string, dto: UpdateCompanionDto) {
    const companion = await this.getOwned(userId, companionId);
    const relationshipId = dto.relationshipId ?? companion.relationshipId;

    if (dto.relationshipId) await this.assertCanUseRelationship(userId, dto.relationshipId);
    if (dto.personalityTraits) await this.assertCanUsePersonality(userId, dto.personalityTraits);
    if (dto.preferredTermId) await this.assertCanUseTerm(userId, relationshipId, dto.preferredTermId);

    return this.prisma.companion.update({
      where: { id: companionId },
      data: {
        name: dto.name,
        relationshipId: dto.relationshipId,
        personalityTraits: dto.personalityTraits as Prisma.InputJsonValue | undefined,
        preferredUserName: dto.preferredUserName,
        preferredTermId: dto.preferredTermId,
        wallpaperId: dto.wallpaperId,
      },
      include: { avatarConfig: true },
    });
  }

  async remove(userId: string, companionId: string) {
    await this.getOwned(userId, companionId);
    await this.prisma.companion.delete({ where: { id: companionId } });
    return { success: true };
  }

  async touchLastInteraction(companionId: string) {
    await this.prisma.companion.update({
      where: { id: companionId },
      data: { lastInteractionAt: new Date() },
    });
  }
}
