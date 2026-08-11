import { Module } from '@nestjs/common';
import { WallpapersController } from './wallpapers.controller';
import { WallpapersService } from './wallpapers.service';

@Module({
  controllers: [WallpapersController],
  providers: [WallpapersService],
})
export class WallpapersModule {}
