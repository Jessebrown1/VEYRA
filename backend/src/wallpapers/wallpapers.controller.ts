import { Controller, Get } from '@nestjs/common';
import { WallpapersService } from './wallpapers.service';

@Controller('wallpapers')
export class WallpapersController {
  constructor(private readonly wallpapersService: WallpapersService) {}

  @Get()
  list() {
    return this.wallpapersService.list();
  }
}
