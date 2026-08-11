import { IsEmail, IsOptional, IsString, MinLength } from 'class-validator';

export class RegisterDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(8)
  password: string;

  // Deferred: the onboarding flow collects this later (the "what should Luna
  // call you" step), not at account creation.
  @IsOptional()
  @IsString()
  preferredName?: string;
}
