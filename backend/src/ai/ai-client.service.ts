import { Injectable, Logger, ServiceUnavailableException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios, { AxiosInstance } from 'axios';

export interface RecentMessagePayload {
  sender: 'user' | 'companion';
  content: string;
}

export interface GenerateReplyPayload {
  companion_name: string;
  personality_traits: Record<string, number>;
  relationship_id: string;
  user_preferred_name: string;
  user_term?: string | null;
  local_hour: number;
  memories: string[];
  area_hint?: string | null;
  recent_messages: RecentMessagePayload[];
  user_message: string;
}

export interface GenerateWelcomePayload {
  companion_name: string;
  personality_traits: Record<string, number>;
  relationship_id: string;
  user_preferred_name: string;
  user_term?: string | null;
  local_hour: number;
}

export interface GenerateNotificationPayload {
  companion_name: string;
  personality_traits: Record<string, number>;
  relationship_id: string;
  user_preferred_name: string;
  reason: 'inactivity' | 'sleep';
  context_hint?: string | null;
}

export interface MemoryCandidate {
  category: string;
  content: string;
  importance: number;
  confidence: number;
}

/** Thin wrapper over the FastAPI AI service. Every call site in the backend goes
 * through here so the AI provider can be swapped later without touching callers. */
@Injectable()
export class AiClientService {
  private readonly logger = new Logger('AiClient');
  private readonly http: AxiosInstance;

  constructor(config: ConfigService) {
    this.http = axios.create({
      baseURL: config.get<string>('AI_SERVICE_URL') ?? 'http://localhost:8000',
      timeout: 60_000,
    });
  }

  private async post<T>(path: string, body: unknown): Promise<T> {
    // The AI service is on Render's free tier and spins down after 15 minutes
    // idle — the first request after that hits a cold, not-yet-listening
    // process and gets rejected almost instantly (not a slow timeout), so a
    // short retry with backoff gives it time to finish booting rather than
    // failing the user's message outright.
    // Render's own free-tier disclaimer is "50 seconds or more" to cold-boot
    // a sleeping service — budget close to that (the Flutter client's own
    // receiveTimeout is 90s) rather than giving up after a token retry.
    const delaysMs = [3_000, 6_000, 12_000, 20_000];
    for (let attempt = 0; ; attempt++) {
      try {
        const { data } = await this.http.post<T>(path, body);
        return data;
      } catch (err) {
        if (attempt >= delaysMs.length) {
          this.logger.error(`AI service call failed: ${path} — ${(err as Error).message}`);
          throw new ServiceUnavailableException({
            code: 'AI_SERVICE_UNAVAILABLE',
            message: 'Your companion is having trouble responding right now. Try again in a moment.',
          });
        }
        this.logger.warn(
          `AI service call failed (attempt ${attempt + 1}), retrying in ${delaysMs[attempt]}ms: ${path} — ${(err as Error).message}`,
        );
        await new Promise((resolve) => setTimeout(resolve, delaysMs[attempt]));
      }
    }
  }

  generateReply(payload: GenerateReplyPayload) {
    return this.post<{ reply: string }>('/generate/reply', payload);
  }

  generateWelcome(payload: GenerateWelcomePayload) {
    return this.post<{ message: string }>('/generate/welcome', payload);
  }

  generateNotification(payload: GenerateNotificationPayload) {
    return this.post<{ message: string }>('/generate/notification', payload);
  }

  extractMemory(payload: { user_message: string; companion_reply: string }) {
    return this.post<{ memories: MemoryCandidate[] }>('/memory/extract', payload);
  }

  embed(text: string) {
    return this.post<{ embedding: number[] }>('/embed', { text });
  }

  /** Fire-and-forget nudge to start the AI service's cold boot as early as
   * possible (called from the app's launch screen, well before the user
   * reaches chat) — a long-idle free-tier instance can take minutes to wake,
   * far more than any request-time retry budget can cover, so getting a
   * head start during onboarding is the real mitigation. */
  warmup(): void {
    this.http.get('/health', { timeout: 5_000 }).catch(() => {
      // Expected while cold — the request itself is what triggers the wake.
    });
  }
}
