import { addDays } from "date-fns";
import { prisma } from "../utils/prisma";
import { generateTermsForTopic, generateDefinitionCard } from "./openAiService";
import { logGeneration } from "./generationLogService";

interface TopicWithRelations {
  id: string;
  name: string;
  maxTerms: number;
}

interface UserTopicWithRelations {
  topicId: string;
  topic: TopicWithRelations;
}

export async function triggerPostOnboardingTermGeneration(
  userId: string,
): Promise<void> {
  console.log(`🎯 Starting post-onboarding generation for user ${userId}`);

  await logGeneration({
    userId,
    promptType: "BULK_GENERATION",
    model: "gpt-4o",
    success: true,
    metadata: { action: "started" },
  });

  try {
    const enabledTopics = (await prisma.userTopic.findMany({
      where: { userId, enabled: true },
      include: { topic: true },
    })) as unknown as UserTopicWithRelations[];

    console.log(
      `📚 Found ${enabledTopics.length} enabled topics for user ${userId}`,
    );

    for (const userTopic of enabledTopics) {
      await generateTermsForUserTopic(userId, userTopic);
    }

    await scheduleFirstTermsForDelivery(userId);

    await logGeneration({
      userId,
      promptType: "BULK_GENERATION",
      model: "gpt-4o",
      success: true,
      metadata: { action: "completed", topicsProcessed: enabledTopics.length },
    });

    console.log(`✅ Completed post-onboarding generation for user ${userId}`);
  } catch (error) {
    console.error("❌ Post-onboarding generation failed:", error);

    await logGeneration({
      userId,
      promptType: "BULK_GENERATION",
      model: "gpt-4o",
      success: false,
      errorMessage: error instanceof Error ? error.message : "Unknown error",
      metadata: { action: "failed" },
    });

    throw error;
  }
}

async function generateTermsForUserTopic(
  userId: string,
  userTopic: UserTopicWithRelations,
): Promise<void> {
  const { topic } = userTopic;

  const existingTermCount = await prisma.term.count({
    where: { topicId: topic.id },
  });

  if (existingTermCount >= topic.maxTerms) {
    console.log(
      `ℹ️ Topic ${topic.name} already has ${existingTermCount}/${topic.maxTerms} terms`,
    );
    return;
  }

  console.log(`🤖 Generating terms for topic ${topic.name}`);

  try {
    const termNames = await generateTermsForTopic(topic.name);

    await logGeneration({
      userId,
      topicId: topic.id,
      promptType: "GENERATION",
      model: "gpt-4o",
      costEstimate: estimateTermGenerationCost(termNames.length),
      success: true,
      metadata: { topicName: topic.name, termCount: termNames.length },
    });

    for (const termName of termNames) {
      await createTermFromCard(userId, topic, termName);
    }

    console.log(
      `✅ Generated ${termNames.length} terms for topic ${topic.name}`,
    );
  } catch (error) {
    console.error(
      `❌ Failed to generate terms for topic ${topic.name}:`,
      error,
    );

    await logGeneration({
      userId,
      topicId: topic.id,
      promptType: "GENERATION",
      model: "gpt-4o",
      success: false,
      errorMessage: error instanceof Error ? error.message : "Unknown error",
      metadata: { topicName: topic.name },
    });
  }
}

async function createTermFromCard(
  userId: string,
  topic: TopicWithRelations,
  termName: string,
): Promise<void> {
  const normalizedTerm = normalizeTerm(termName);

  const existingTerm = await prisma.term.findFirst({
    where: {
      topicId: topic.id,
      term: { equals: normalizedTerm, mode: "insensitive" },
    },
  });

  if (existingTerm) {
    console.log(
      `ℹ️ Term ${normalizedTerm} already exists for topic ${topic.name}`,
    );
    return;
  }

  try {
    const card = await generateDefinitionCard(topic.name, normalizedTerm);

    await logGeneration({
      userId,
      topicId: topic.id,
      promptType: "DEFINITION",
      model: "gpt-4o",
      costEstimate: estimateDefinitionCost(card),
      success: true,
      metadata: { topicName: topic.name, term: normalizedTerm },
    });

    const createdTerm = await prisma.term.create({
      data: {
        topicId: topic.id,
        term: normalizedTerm,
        definition: card.definition,
        example: Array.isArray(card.examples) ? (card.examples[0] ?? "") : "",
        source: "AI Generated",
        sourceUrl: undefined,
        verified: false,
        gptGenerated: true,
        confidenceScore: 0.8,
        category: "Vocabulary",
        complexityLevel: "intermediate",
        moderationStatus: "approved",
      },
    });

    await logGeneration({
      userId,
      topicId: topic.id,
      termId: createdTerm.id,
      promptType: "DEFINITION",
      model: "gpt-4o",
      success: true,
      metadata: {
        topicName: topic.name,
        term: normalizedTerm,
        action: "term_created",
      },
    });

    console.log(`✅ Created term ${normalizedTerm} for topic ${topic.name}`);
  } catch (error) {
    console.error(`❌ Failed to create term ${normalizedTerm}:`, error);

    await logGeneration({
      userId,
      topicId: topic.id,
      promptType: "DEFINITION",
      model: "gpt-4o",
      success: false,
      errorMessage: error instanceof Error ? error.message : "Unknown error",
      metadata: { topicName: topic.name, term: normalizedTerm },
    });
  }
}

async function scheduleFirstTermsForDelivery(userId: string): Promise<void> {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { dailyWordGoal: true },
  });

  const dailyGoal = user?.dailyWordGoal ?? 1;

  const enabledTopics = await prisma.userTopic.findMany({
    where: { userId, enabled: true },
    include: { topic: true },
  });

  const topicIds = enabledTopics.map(({ topicId }) => topicId);
  const existingWordbankEntries = await prisma.wordbank.findMany({
    where: { userId },
    select: { termId: true },
  });

  const alreadyScheduledTermIds = new Set(
    existingWordbankEntries.map((entry) => entry.termId),
  );

  const availableTerms = await prisma.term.findMany({
    where: {
      topicId: { in: topicIds },
      moderationStatus: "approved",
      id: { notIn: Array.from(alreadyScheduledTermIds) },
    },
    orderBy: { createdAt: "desc" },
    take: dailyGoal,
  });

  for (const term of availableTerms) {
    await prisma.wordbank.create({
      data: {
        userId,
        termId: term.id,
        status: "LEARNING",
        bucket: 1,
        relevance: "RELATED",
        nextReview: addDays(new Date(), 1),
      },
    });

    await prisma.delivery.create({
      data: {
        userId,
        termId: term.id,
        deliveredAt: new Date(),
      },
    });
  }

  console.log(`📬 Scheduled ${availableTerms.length} terms for user ${userId}`);
}

function normalizeTerm(term: string): string {
  return term.trim().toLowerCase();
}

function estimateTermGenerationCost(termCount: number): number {
  return Math.max(0, termCount * 0.01);
}

function estimateDefinitionCost(card: Record<string, unknown>): number {
  const approxSize = JSON.stringify(card).length;
  return Math.max(0.02, (approxSize / 1000) * 0.01);
}
