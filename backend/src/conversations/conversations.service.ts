import { ForbiddenException, Injectable, Logger, NotFoundException } from '@nestjs/common';
import { Companion, MessageSender } from '@prisma/client';
import { AiClientService } from '../ai/ai-client.service';
import { termsForRelationship } from '../companions/catalog';
import { CompanionsService } from '../companions/companions.service';
import { MemoriesService } from '../memories/memories.service';
import { PrismaService } from '../prisma/prisma.service';

const RECENT_MESSAGE_COUNT = 12;
const FORGET_INTENT = /^\s*forget\s+(that\s+)?/i;

@Injectable()
export class ConversationsService {
  private readonly logger = new Logger('ConversationsService');

  constructor(
    private readonly prisma: PrismaService,
    private readonly companions: CompanionsService,
    private readonly memories: MemoriesService,
    private readonly ai: AiClientService,
  ) {}

  async listForUser(userId: string) {
    return this.prisma.conversation.findMany({
      where: { companion: { userId } },
      orderBy: { updatedAt: 'desc' },
    });
  }

  async getOrCreateDefault(userId: string, companionId: string) {
    const companion = await this.companions.getOwned(userId, companionId);
    const existing = await this.prisma.conversation.findFirst({
      where: { companionId },
      orderBy: { createdAt: 'desc' },
      include: { _count: { select: { messages: true } } },
    });

    const conversation = existing ?? (await this.prisma.conversation.create({ data: { companionId } }));

    // Seed a welcome message whenever the conversation has none yet — covers
    // both a brand-new conversation and one left empty by a previous attempt
    // where the AI call failed after the conversation row was already created.
    if (!existing || existing._count.messages === 0) {
      await this.seedWelcomeMessage(userId, companion, conversation.id);
    }

    return conversation;
  }

  private async seedWelcomeMessage(userId: string, companion: Companion, conversationId: string) {
    try {
      const user = await this.prisma.user.findUniqueOrThrow({ where: { id: userId } });
      const { message } = await this.ai.generateWelcome({
        companion_name: companion.name,
        personality_traits: companion.personalityTraits as Record<string, number>,
        relationship_id: companion.relationshipId,
        user_preferred_name: companion.preferredUserName,
        user_term: this.userTermFor(companion),
        local_hour: this.localHourFor(user.timezone),
      });
      await this.prisma.message.create({
        data: { conversationId, sender: MessageSender.companion, content: message },
      });
    } catch (err) {
      // Don't fail conversation creation over a welcome message — the user can
      // still chat normally, and the next getOrCreateDefault call will retry
      // seeding since the conversation is still empty.
      this.logger.warn(`Welcome message seed failed (non-fatal): ${(err as Error).message}`);
    }
  }

  async listMessages(userId: string, conversationId: string) {
    const conversation = await this.getOwnedConversation(userId, conversationId);
    return this.prisma.message.findMany({
      where: { conversationId: conversation.id },
      orderBy: { createdAt: 'asc' },
    });
  }

  private async getOwnedConversation(userId: string, conversationId: string) {
    const conversation = await this.prisma.conversation.findUnique({
      where: { id: conversationId },
      include: { companion: true },
    });
    if (!conversation) {
      throw new NotFoundException({ code: 'CONVERSATION_NOT_FOUND', message: 'Conversation not found.' });
    }
    if (conversation.companion.userId !== userId) {
      throw new ForbiddenException({
        code: 'NOT_YOUR_CONVERSATION',
        message: 'You do not have access to this conversation.',
      });
    }
    return conversation;
  }

  private localHourFor(timezone: string): number {
    try {
      const formatted = new Intl.DateTimeFormat('en-US', {
        hour: 'numeric',
        hour12: false,
        timeZone: timezone,
      }).format(new Date());
      return Number(formatted) % 24;
    } catch {
      return new Date().getUTCHours();
    }
  }

  private userTermFor(companion: { relationshipId: string; preferredTermId: string }): string | null {
    const termEntry = termsForRelationship(companion.relationshipId).find(
      (t) => t.id === companion.preferredTermId,
    );
    return termEntry && termEntry.id !== 'first_name' ? termEntry.id : null;
  }

  async postMessage(userId: string, conversationId: string, content: string) {
    const conversation = await this.getOwnedConversation(userId, conversationId);
    const companion = conversation.companion;
    const user = await this.prisma.user.findUniqueOrThrow({ where: { id: userId } });

    const userMessage = await this.prisma.message.create({
      data: { conversationId, sender: MessageSender.user, content },
    });

    // Natural-language "forget X" — handled as intent detection on the message itself
    // rather than a separate NLU system, per the memory-privacy requirement that
    // forgetting must actually deactivate the memory, not just pretend to.
    if (FORGET_INTENT.test(content)) {
      const phrase = content.replace(FORGET_INTENT, '').trim();
      const forgotten = phrase ? await this.memories.forgetBySimilarity(userId, companion.id, phrase) : null;
      const reply = forgotten ? "Okay. I'll forget that." : "I don't think I have that saved, but okay.";
      const companionMessage = await this.prisma.message.create({
        data: { conversationId, sender: MessageSender.companion, content: reply },
      });
      await this.companions.touchLastInteraction(companion.id);
      return { userMessage, companionMessage };
    }

    const recentMessages = await this.prisma.message.findMany({
      where: { conversationId, id: { not: userMessage.id } },
      orderBy: { createdAt: 'desc' },
      take: RECENT_MESSAGE_COUNT,
    });
    recentMessages.reverse();

    const { embedding } = await this.ai.embed(content);
    const relevantMemories = await this.memories.retrieveRelevant(companion.id, embedding);

    const { reply } = await this.ai.generateReply({
      companion_name: companion.name,
      personality_traits: companion.personalityTraits as Record<string, number>,
      relationship_id: companion.relationshipId,
      user_preferred_name: companion.preferredUserName,
      user_term: this.userTermFor(companion),
      local_hour: this.localHourFor(user.timezone),
      memories: relevantMemories,
      recent_messages: recentMessages.map((m) => ({
        sender: m.sender as 'user' | 'companion',
        content: m.content,
      })),
      user_message: content,
    });

    const companionMessage = await this.prisma.message.create({
      data: { conversationId, sender: MessageSender.companion, content: reply },
    });

    await this.companions.touchLastInteraction(companion.id);

    // Non-blocking — the user shouldn't wait on memory extraction to see their reply.
    void this.memories.extractAndStore(userId, companion.id, userMessage.id, content, reply);

    return { userMessage, companionMessage };
  }
}
