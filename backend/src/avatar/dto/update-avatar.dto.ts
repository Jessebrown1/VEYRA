import { IsOptional, IsString } from 'class-validator';

export class UpdateAvatarDto {
  @IsOptional()
  @IsString()
  skinAssetId?: string;

  @IsOptional()
  @IsString()
  hairAssetId?: string;

  @IsOptional()
  @IsString()
  eyeAssetId?: string;

  @IsOptional()
  @IsString()
  outfitAssetId?: string;

  @IsOptional()
  @IsString()
  accessoryAssetId?: string;
}
