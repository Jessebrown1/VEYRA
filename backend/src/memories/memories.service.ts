import { ForbiddenException, Injectable, Logger, NotFoundException } from '@nestjs/common';
import { MemoryCategory } from '@prisma/client';
import { AiClientService } from '../ai/ai-client.service';
import { EntitlementsService } from '../entitlements/entitlements.service';
import { PrismaService } from '../prisma/prisma.service';

const VALID_CATEGORIES = new Set<string>([
  'identity',
  'preferences',
  'interests',
  'relationships',
  'goals',
  'important_dates',
  'routines',
  'locations',
  'education',
  'work',
  'personal_facts',
  'conversation_context',
]);

/** How close (cosine distance) a "forget X" phrase must be to an existing memory
 * before we treat it as a match worth deactivating. Lower = stricter. */
const FORGET_DISTANCE_THRESHOLD = 0.35;

@Injectable()
export class MemoriesService {
  private readonly logger = new Logger('MemoriesService');

  constructor(
    private readonly prisma: PrismaService,
    private readonly ai: AiClientService,
    private readonly entitlements: EntitlementsService,
  ) {}

  async listForCompanion(userId: string, companionId: string) {
    await this.assertOwnsCompanion(userId, companionId);
    return this.prisma.memory.findMany({
      where: { companionId, isActive: true },
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        category: true,
        content: true,
        importance: true,
        confidence: true,
        createdAt: true,
      },
    });
  }

  async update(userId: string, memoryId: string, content: string) {
    const memory = await this.getOwned(userId, memoryId);
    return this.prisma.memory.update({ where: { id: memory.id }, data: { content } });
  }

  async deactivate(userId: string, memoryId: string) {
    const memory = await this.getOwned(userId, memoryId);
    await this.prisma.memory.update({ where: { id: memory.id }, data: { isActive: false } });
    return { success: true };
  }

  async clearAllForCompanion(userId: string, companionId: string) {
    await this.assertOwnsCompanion(userId, companionId);
    await this.prisma.memory.updateMany({ where: { companionId }, data: { isActive: false } });
    return { success: true };
  }

  private async getOwned(userId: string, memoryId: string) {
    const memory = await this.prisma.memory.findUnique({ where: { id: memoryId } });
    if (!memory) {
      throw new NotFoundException({ code: 'MEMORY_NOT_FOUND', message: 'Memory not found.' });
    }
    if (memory.userId !== userId) {
      throw new ForbiddenException({ code: 'NOT_YOUR_MEMORY', message: 'You do not have access to this memory.' });
    }
    return memory;
  }

  private async assertOwnsCompanion(userId: string, companionId: string) {
    const companion = await this.prisma.companion.findUnique({ where: { id: companionId } });
    if (!companion) {
      throw new NotFoundException({ code: 'COMPANION_NOT_FOUND', message: 'Companion not found.' });
    }
    if (companion.userId !== userId) {
      throw new ForbiddenException({
        code: 'NOT_YOUR_COMPANION',
        message: 'You do not have access to this companion.',
      });
    }
  }

  /** Natural-language "forget X" support: finds the active memory whose content is most
   * semantically similar to the phrase and deactivates it if the match is close enough.
   * Returns the deactivated content, or null if nothing matched well. */
  async forgetBySimilarity(userId: string, companionId: string, phrase: string): Promise<string | null> {
    await this.assertOwnsCompanion(userId, companionId);
    const { embedding } = await this.ai.embed(phrase);
    const embeddingLiteral = `[${embedding.join(',')}]`;

    const rows = await this.prisma.$queryRawUnsafe<{ id: string; content: string; distance: number }[]>(
      `SELECT id, content, embedding <=> $1::vector AS distance
       FROM "Memory"
       WHERE "companionId" = $2 AND "isActive" = true AND embedding IS NOT NULL
       ORDER BY distance ASC
       LIMIT 1`,
      embeddingLiteral,
      companionId,
    );

    const best = rows[0];
    if (!best || best.distance > FORGET_DISTANCE_THRESHOLD) return null;

    await this.prisma.memory.update({ where: { id: best.id }, data: { isActive: false } });
    return best.content;
  }

  /** Top-k relevant active memories for a query — never dumps the whole memory table
   * into the AI prompt. */
  async retrieveRelevant(companionId: string, queryEmbedding: number[], topK = 6): Promise<string[]> {
    const embeddingLiteral = `[${queryEmbedding.join(',')}]`;
    const rows = await this.prisma.$queryRawUnsafe<{ content: string }[]>(
      `SELECT content
       FROM "Memory"
       WHERE "companionId" = $1 AND "isActive" = true AND embedding IS NOT NULL
         AND importance >= 0.25 AND confidence >= 0.25
       ORDER BY embedding <=> $2::vector
       LIMIT $3`,
      companionId,
      embeddingLiteral,
      topK,
    );
    return rows.map((r) => r.content);
  }

  /** Extracts candidate memories from an exchange, embeds and stores the useful ones,
   * respecting the user's free/plus memory limit by evicting the least important
   * memory rather than dropping randomly. Failures here never break the chat response —
   * this is called without being awaited by the caller. */
  async extractAndStore(
    userId: string,
    companionId: string,
    sourceMessageId: string,
    userMessage: string,
    companionReply: string,
  ) {
    try {
      const { memories } = await this.ai.extractMemory({ user_message: userMessage, companion_reply: companionReply });
      if (memories.length === 0) return;

      const limit = await this.entitlements.memoryLimit(userId);

      for (const candidate of memories) {
        if (!VALID_CATEGORIES.has(candidate.category)) continue;

        const activeCount = await this.prisma.memory.count({ where: { companionId, isActive: true } });
        if (activeCount >= limit && candidate.importance < 0.6) continue;

        const { embedding } = await this.ai.embed(candidate.content);
        const created = await this.prisma.memory.create({
          data: {
            userId,
            companionId,
            category: candidate.category as MemoryCategory,
            content: candidate.content,
            importance: candidate.importance,
            confidence: candidate.confidence,
            sourceMessageId,
          },
        });

        const embeddingLiteral = `[${embedding.join(',')}]`;
        await this.prisma.$executeRawUnsafe(
          `UPDATE "Memory" SET embedding = $1::vector WHERE id = $2`,
          embeddingLiteral,
          created.id,
        );

        if (activeCount >= limit) {
          const weakest = await this.prisma.memory.findFirst({
            where: { companionId, isActive: true, id: { not: created.id } },
            orderBy: [{ importance: 'asc' }, { createdAt: 'asc' }],
          });
          if (weakest) {
            await this.prisma.memory.update({ where: { id: weakest.id }, data: { isActive: false } });
          }
        }
      }
    } catch (err) {
      this.logger.warn(`Memory extraction failed (non-fatal): ${(err as Error).message}`);
    }
  }
}
