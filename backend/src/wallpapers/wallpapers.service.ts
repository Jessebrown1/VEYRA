import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class WallpapersService {
  constructor(private readonly prisma: PrismaService) {}

  async list() {
    return this.prisma.wallpaperAsset.findMany({
      where: { isActive: true },
      orderBy: [{ category: 'asc' }, { name: 'asc' }],
    });
  }
}
