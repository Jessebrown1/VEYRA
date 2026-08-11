import { Injectable, NotFoundException, UnauthorizedException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { ChangePasswordDto } from './dto/change-password.dto';
import { UpdateUserDto } from './dto/update-user.dto';

const SALT_ROUNDS = 12;

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async me(userId: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new NotFoundException({ code: 'USER_NOT_FOUND', message: 'User not found.' });
    return this.toPublic(user);
  }

  async update(userId: string, dto: UpdateUserDto) {
    const user = await this.prisma.user.update({ where: { id: userId }, data: dto });
    return this.toPublic(user);
  }

  async changePassword(userId: string, dto: ChangePasswordDto) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new NotFoundException({ code: 'USER_NOT_FOUND', message: 'User not found.' });

    const valid = await bcrypt.compare(dto.currentPassword, user.passwordHash);
    if (!valid) {
      throw new UnauthorizedException({ code: 'INVALID_PASSWORD', message: 'Current password is incorrect.' });
    }

    const passwordHash = await bcrypt.hash(dto.newPassword, SALT_ROUNDS);
    await this.prisma.user.update({ where: { id: userId }, data: { passwordHash } });
    return { success: true };
  }

  async deleteAccount(userId: string) {
    // Every child table cascades from User in the schema (companions ->
    // conversations -> messages/memories/avatarConfig, subscription,
    // notification/location settings, sent notifications), so a single
    // delete here is a complete account wipe.
    await this.prisma.user.delete({ where: { id: userId } });
    return { success: true };
  }

  async exportData(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        subscription: true,
        notificationSettings: true,
        locationSettings: true,
        companions: {
          include: {
            avatarConfig: true,
            memories: { where: { isActive: true } },
            conversations: {
              include: {
                messages: { orderBy: { createdAt: 'asc' } },
              },
            },
          },
        },
      },
    });
    if (!user) throw new NotFoundException({ code: 'USER_NOT_FOUND', message: 'User not found.' });

    const { passwordHash: _passwordHash, ...publicUser } = user;
    return {
      exportedAt: new Date().toISOString(),
      user: publicUser,
    };
  }

  private toPublic(user: { id: string; email: string; preferredName: string | null; timezone: string }) {
    return {
      id: user.id,
      email: user.email,
      preferredName: user.preferredName,
      timezone: user.timezone,
    };
  }
}
