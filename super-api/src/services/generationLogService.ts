import { prisma } from "../utils/prisma";
import { supabase } from "../config/supabase";

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
    // Try Prisma first (for Prisma-based environments)
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
      return;
    } catch (prismaError) {
      console.log("Prisma logging failed, trying Supabase...");
    }

    // Fallback to Supabase logging
    if (supabase) {
      const { error } = await supabase
        .from('GenerationLog')
        .insert({
          id: `gl-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
          userId: data.userId,
          topicId: data.topicId,
          termId: data.termId,
          promptType: data.promptType,
          model: data.model,
          costEstimate: data.costEstimate,
          success: data.success,
          errorMessage: data.errorMessage,
          metadata: data.metadata ?? {},
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        });

      if (error) {
        console.error("Supabase logging failed:", error);
      }
    }
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
