import { IsObject, IsOptional, IsString } from 'class-validator';

export class UpdateCompanionDto {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsString()
  relationshipId?: string;

  @IsOptional()
  @IsObject()
  personalityTraits?: Record<string, number>;

  @IsOptional()
  @IsString()
  preferredUserName?: string;

  @IsOptional()
  @IsString()
  preferredTermId?: string;

  @IsOptional()
  @IsString()
  wallpaperId?: string;
}
