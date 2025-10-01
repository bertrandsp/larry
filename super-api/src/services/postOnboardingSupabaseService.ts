import { addDays } from "date-fns";
import { supabase } from "../config/supabase";
import {
  generateTermsForTopic,
  generateDefinitionCard,
} from "./openAiService";
import { logGeneration } from "./generationLogService";
import { processVocabularyCard } from "../utils/vocabularyUtils";

const DEFAULT_MAX_TERMS = 10;

type SupabaseTopicRow = {
  topicId: string;
  enabled?: boolean | null;
  topic: {
    id: string;
    name: string;
    maxTerms?: number | null;
  } | null;
};

export async function triggerSupabasePostOnboarding(
  userId: string,
): Promise<void> {
  if (!supabase) {
    console.warn(
      "⚠️ Supabase client not configured; skipping post-onboarding generation",
    );
    return;
  }

  console.log(
    `🎯 [Supabase] Starting post-onboarding generation for user ${userId}`,
  );

  await logGeneration({
    userId,
    promptType: "BULK_GENERATION",
    model: "gpt-4o",
    success: true,
    metadata: { action: "started", backend: "supabase" },
  });

  try {
    const { data: topicRows, error: topicError } = await supabase
      .from("UserTopic")
      .select(`topicId, enabled, topic:Topic(id, name, maxTerms)`)
      .eq("userId", userId);

    if (topicError) {
      throw topicError;
    }

    const userTopics = (topicRows ?? [])
      .filter((row: any) => Boolean(row?.topic))
      .filter((row: any) => row.enabled ?? true);

    console.log(
      `📚 [Supabase] Found ${userTopics.length} topics for user ${userId}`,
    );

    const createdTermIds: string[] = [];

    for (const userTopic of userTopics) {
      const topicRecord = userTopic.topic as any;
      const maxTerms = topicRecord.maxTerms ?? DEFAULT_MAX_TERMS;

      const { data: existingTermsData, error: existingTermsError } = await supabase
        .from("Term")
        .select("id, term")
        .eq("topicId", topicRecord.id);

      if (existingTermsError) {
        console.error(
          "❌ [Supabase] Failed to fetch existing terms",
          existingTermsError,
        );
        continue;
      }

      const existingTerms = existingTermsData ?? [];
      const existingTermSet = new Set(
        existingTerms
          .map((row) => (row.term ?? "").toLowerCase())
          .filter((value) => value.length > 0),
      );

      if (existingTerms.length >= maxTerms) {
        console.log(
          `ℹ️ [Supabase] Topic ${topicRecord.name} already has ${existingTerms.length}/${maxTerms} terms`,
        );
        continue;
      }

      console.log(`🤖 [Supabase] Generating terms for topic ${topicRecord.name}`);

      let termNames: string[] = [];
      try {
        termNames = await generateTermsForTopic(topicRecord.name);

        await logGeneration({
          userId,
          topicId: topicRecord.id,
          promptType: "GENERATION",
          model: "gpt-4o",
          costEstimate: estimateTermGenerationCost(termNames.length),
          success: true,
          metadata: { topicName: topicRecord.name, termCount: termNames.length },
        });
      } catch (generationError) {
        console.error(
          `❌ [Supabase] Failed to generate terms for ${topicRecord.name}`,
          generationError,
        );
        await logGeneration({
          userId,
          topicId: topicRecord.id,
          promptType: "GENERATION",
          model: "gpt-4o",
          success: false,
          errorMessage:
            generationError instanceof Error
              ? generationError.message
              : "Unknown error",
          metadata: { topicName: topicRecord.name },
        });
        continue;
      }

      for (const termName of termNames) {
        const normalizedTerm = normalizeTerm(termName);
        if (!normalizedTerm || existingTermSet.has(normalizedTerm)) {
          continue;
        }

        try {
          const card = await generateDefinitionCard(
            topicRecord.name,
            normalizedTerm,
          );

          await logGeneration({
            userId,
            topicId: topicRecord.id,
            promptType: "DEFINITION",
            model: "gpt-4o",
            costEstimate: estimateDefinitionCost(card),
            success: true,
            metadata: { topicName: topicRecord.name, term: normalizedTerm },
          });

          const nowIso = new Date().toISOString();
          
          // Process rich vocabulary data from OpenAI card
          const richVocabFields = processVocabularyCard(card, topicRecord.name);
          
          const termPayload = {
            id: `term-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
            topicId: topicRecord.id,
            term: (card.term || normalizedTerm).trim(),
            definition: card.definition,
            example: Array.isArray(card.examples) ? card.examples[0] ?? "" : "",
            
            // 🔥 NEW: Rich vocabulary fields
            synonyms: richVocabFields.synonyms,
            antonyms: richVocabFields.antonyms,
            relatedTerms: richVocabFields.relatedTerms,
            partOfSpeech: richVocabFields.partOfSpeech,
            difficulty: richVocabFields.difficulty,
            tags: richVocabFields.tags,
            etymology: richVocabFields.etymology,
            pronunciation: richVocabFields.pronunciation,
            
            source: "AI Generated",
            sourceUrl: undefined,
            verified: false,
            gptGenerated: true,
            confidenceScore: 0.8,
            category: "Vocabulary",
            complexityLevel: "intermediate",
            moderationStatus: "approved",
            createdAt: nowIso,
            updatedAt: nowIso,
          };

          const { data: insertedTerm, error: insertError } = await supabase
            .from("Term")
            .insert(termPayload)
            .select("id")
            .single();

          if (insertError) {
            console.error(
              `❌ [Supabase] Failed to insert term ${normalizedTerm}`,
              insertError,
            );
            continue;
          }

          if (insertedTerm?.id) {
            createdTermIds.push(insertedTerm.id);
            existingTermSet.add(termPayload.term.toLowerCase());
          }
        } catch (definitionError) {
          console.error(
            `❌ [Supabase] Failed to create term ${normalizedTerm}`,
            definitionError,
          );

          await logGeneration({
            userId,
            topicId: topicRecord.id,
            promptType: "DEFINITION",
            model: "gpt-4o",
            success: false,
            errorMessage:
              definitionError instanceof Error
                ? definitionError.message
                : "Unknown error",
            metadata: { topicName: topicRecord.name, term: normalizedTerm },
          });
        }
      }
    }

    if (createdTermIds.length > 0) {
      await scheduleFirstSupabaseTerms(userId, createdTermIds);
    }

    await logGeneration({
      userId,
      promptType: "BULK_GENERATION",
      model: "gpt-4o",
      success: true,
      metadata: {
        action: "completed",
        backend: "supabase",
        termsCreated: createdTermIds.length,
      },
    });
  } catch (error) {
    console.error("❌ [Supabase] Post-onboarding generation failed", error);
    await logGeneration({
      userId,
      promptType: "BULK_GENERATION",
      model: "gpt-4o",
      success: false,
      errorMessage: error instanceof Error ? error.message : "Unknown error",
      metadata: { action: "failed", backend: "supabase" },
    });
    throw error;
  }
}

async function scheduleFirstSupabaseTerms(
  userId: string,
  termIds: string[],
): Promise<void> {
  if (!supabase || termIds.length === 0) {
    console.log("ℹ️ [Supabase] No terms to schedule");
    return;
  }

  const { data: userRow, error: userError } = await supabase
    .from("User")
    .select("dailyWordGoal")
    .eq("id", userId)
    .single();

  if (userError) {
    console.error(
      "❌ [Supabase] Failed to fetch user preferences",
      userError,
    );
    return;
  }

  const dailyGoal = userRow?.dailyWordGoal ?? 1;
  const termsToSchedule = termIds.slice(0, dailyGoal);

  let scheduledCount = 0;

  for (const termId of termsToSchedule) {
    const { data: existingWordbankRows, error: wordbankSelectError } = await supabase
      .from("Wordbank")
      .select("id")
      .eq("userId", userId)
      .eq("termId", termId);

    if (wordbankSelectError) {
      console.error(
        "❌ [Supabase] Failed to check wordbank entry",
        wordbankSelectError,
      );
      continue;
    }

    if (existingWordbankRows && existingWordbankRows.length > 0) {
      continue;
    }

    const nowIso = new Date().toISOString();

    const { data: createdWordbank, error: createWordbankError } = await supabase
      .from("Wordbank")
      .insert({
        userId,
        termId,
        status: "LEARNING",
        bucket: 1,
        reviewCount: 0,
        relevance: "RELATED",
        nextReview: addDays(new Date(), 1).toISOString(),
      })
      .select("id")
      .single();

    if (createWordbankError) {
      console.error(
        "❌ [Supabase] Failed to create wordbank entry",
        createWordbankError,
      );
      continue;
    }

    const { error: deliveryError } = await supabase.from("Delivery").insert({
      userId,
      termId,
      deliveredAt: nowIso,
      action: "NONE",
    });

    if (deliveryError) {
      console.error(
        "❌ [Supabase] Failed to create delivery entry",
        deliveryError,
      );
      continue;
    }

    if (createdWordbank?.id) {
      scheduledCount += 1;
    }
  }

  console.log(`📬 [Supabase] Scheduled ${scheduledCount} terms for user ${userId}`);
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
