import { IsBoolean, IsIn, IsOptional, IsString, Matches } from 'class-validator';

export class UpdateNotificationSettingsDto {
  @IsOptional()
  @IsBoolean()
  enabled?: boolean;

  @IsOptional()
  @IsBoolean()
  companionCheckins?: boolean;

  @IsOptional()
  @IsBoolean()
  sleepReminders?: boolean;

  @IsOptional()
  @IsBoolean()
  quietHoursEnabled?: boolean;

  @IsOptional()
  @IsString()
  @Matches(/^\d{2}:\d{2}$/)
  quietStart?: string;

  @IsOptional()
  @IsString()
  @Matches(/^\d{2}:\d{2}$/)
  quietEnd?: string;

  @IsOptional()
  @IsIn(['low', 'normal', 'high'])
  frequency?: string;
}
