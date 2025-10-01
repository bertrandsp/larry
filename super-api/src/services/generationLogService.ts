import { prisma } from "../utils/prisma";

type PromptType =
  | "GENERATION"
  | "DEFINITION"
  | "BULK_GENERATION"
  | "USER_ACTION";

type GenerationLogInput = {
  userId: string;
  topicId?: string;
  termId?: string;
  promptType: PromptType;
  model: string;
  costEstimate?: number;
  success: boolean;
  errorMessage?: string;
  metadata?: Record<string, unknown>;
};

export async function logGeneration(data: GenerationLogInput): Promise<void> {
  try {
    await prisma.generationLog.create({
      data: {
        userId: data.userId,
        topicId: data.topicId,
        termId: data.termId,
        promptType: data.promptType,
        model: data.model,
        costEstimate: data.costEstimate,
        success: data.success,
        errorMessage: data.errorMessage,
        metadata: (data.metadata ?? {}) as any,
      },
    });
  } catch (error) {
    console.error("Failed to log generation event", error);
  }
}

export async function getGenerationStats(
  userId: string,
  days: number = 30,
): Promise<{
  totalCost: number;
  totalEvents: number;
  successfulEvents: number;
}> {
  const since = new Date(Date.now() - days * 24 * 60 * 60 * 1000);

  const result = await prisma.generationLog.aggregate({
    where: {
      userId,
      createdAt: { gte: since },
    },
    _sum: {
      costEstimate: true,
    },
    _count: {
      _all: true,
      id: true,
    },
  });

  const successfulCount = await prisma.generationLog.count({
    where: {
      userId,
      createdAt: { gte: since },
      success: true,
    },
  });

  return {
    totalCost: result._sum.costEstimate ?? 0,
    totalEvents: result._count._all,
    successfulEvents: successfulCount,
  };
}
