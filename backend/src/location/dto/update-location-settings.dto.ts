import { IsBoolean, IsIn, IsOptional, IsString } from 'class-validator';

export class UpdateLocationSettingsDto {
  @IsOptional()
  @IsBoolean()
  enabled?: boolean;

  @IsOptional()
  @IsIn(['none', 'approximate', 'precise'])
  permissionType?: string;

  /** An approximate area string (e.g. "Osu, Accra") — never raw GPS coordinates. */
  @IsOptional()
  @IsString()
  lastArea?: string;
}
