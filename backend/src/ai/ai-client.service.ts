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
    try {
      const { data } = await this.http.post<T>(path, body);
      return data;
    } catch (err) {
      this.logger.error(`AI service call failed: ${path} — ${(err as Error).message}`);
      throw new ServiceUnavailableException({
        code: 'AI_SERVICE_UNAVAILABLE',
        message: 'Your companion is having trouble responding right now. Try again in a moment.',
      });
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
}
