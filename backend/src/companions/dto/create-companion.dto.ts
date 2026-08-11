import { IsNotEmpty, IsObject, IsOptional, IsString } from 'class-validator';

export class CreateCompanionDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsNotEmpty()
  relationshipId: string;

  @IsObject()
  personalityTraits: Record<string, number>;

  @IsString()
  @IsNotEmpty()
  preferredUserName: string;

  @IsString()
  @IsNotEmpty()
  preferredTermId: string;

  @IsOptional()
  @IsString()
  wallpaperId?: string;
}
