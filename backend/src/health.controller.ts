import { Controller, Get } from '@nestjs/common';
import { AiClientService } from './ai/ai-client.service';
import { Public } from './common/decorators/public.decorator';

@Controller()
export class HealthController {
  constructor(private readonly aiClient: AiClientService) {}

  @Public()
  @Get('health')
  health() {
    return { status: 'ok' };
  }

  /** Called from the app's splash screen so the AI service starts waking up
   * the moment the app opens, instead of only when a message is sent. */
  @Public()
  @Get('ai/warmup')
  warmupAi() {
    this.aiClient.warmup();
    return { status: 'ok' };
  }
}
