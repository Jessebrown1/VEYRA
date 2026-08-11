import { Body, Controller, Get, Patch } from '@nestjs/common';
import { CurrentUser, type AuthenticatedUser } from '../common/decorators/current-user.decorator';
import { UpdateLocationSettingsDto } from './dto/update-location-settings.dto';
import { LocationService } from './location.service';

@Controller('location')
export class LocationController {
  constructor(private readonly locationService: LocationService) {}

  @Get('settings')
  getSettings(@CurrentUser() user: AuthenticatedUser) {
    return this.locationService.getSettings(user.userId);
  }

  @Patch('settings')
  updateSettings(@CurrentUser() user: AuthenticatedUser, @Body() dto: UpdateLocationSettingsDto) {
    return this.locationService.updateSettings(user.userId, dto);
  }
}
