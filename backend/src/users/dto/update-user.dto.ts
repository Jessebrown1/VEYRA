import { IsOptional, IsString, MinLength } from 'class-validator';

export class UpdateUserDto {
  @IsOptional()
  @IsString()
  @MinLength(1)
  preferredName?: string;

  @IsOptional()
  @IsString()
  timezone?: string;
}
