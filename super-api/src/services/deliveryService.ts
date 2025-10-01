import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

export interface DeliveryResult {
  id: string;
  userId: string;
  termId: string;
  deliveredAt: Date;
  action: string;
}

export interface WordbankEntry {
  id: string;
  userId: string;
  termId: string;
  status: string;
  bucket: number;
  lastReviewed?: Date;
  nextReview?: Date;
  reviewCount: number;
}

/**
 * Create a delivery record for a word delivered to a user
 */
export async function createDelivery(
  userId: string,
  termId: string,
): Promise<DeliveryResult> {
  console.log(`📦 Creating delivery record for user ${userId}, term ${termId}`);

  try {
    const delivery = await prisma.delivery.create({
      data: {
        userId,
        termId,
        action: "NONE",
      },
    });

    console.log(`✅ Delivery created: ${delivery.id}`);
    return {
      id: delivery.id,
      userId: delivery.userId,
      termId: delivery.termId,
      deliveredAt: delivery.deliveredAt,
      action: delivery.action,
    };
  } catch (error) {
    console.error(`❌ Failed to create delivery:`, error);
    throw error;
  }
}

/**
 * Update delivery action when user interacts with the word
 */
export async function updateDeliveryAction(
  deliveryId: string,
  action: "FAVORITE" | "LEARN_AGAIN" | "MASTERED",
): Promise<void> {
  console.log(`🔄 Updating delivery ${deliveryId} with action: ${action}`);

  try {
    await prisma.delivery.update({
      where: { id: deliveryId },
      data: {
        action,
        openedAt: new Date(), // Mark as opened when action is taken
      },
    });

    console.log(`✅ Delivery action updated: ${action}`);
  } catch (error) {
    console.error(`❌ Failed to update delivery action:`, error);
    throw error;
  }
}

/**
 * Add a word to user's wordbank for spaced repetition
 */
export async function addToWordbank(
  userId: string,
  termId: string,
): Promise<WordbankEntry> {
  console.log(`📚 Adding term ${termId} to wordbank for user ${userId}`);

  try {
    // Check if already in wordbank
    const existing = await prisma.wordbank.findUnique({
      where: {
        userId_termId: {
          userId,
          termId,
        },
      },
    });

    if (existing) {
      console.log(`ℹ️ Term already in wordbank: ${existing.id}`);
      return {
        id: existing.id,
        userId: existing.userId,
        termId: existing.termId,
        status: existing.status,
        bucket: existing.bucket,
        lastReviewed: existing.lastReviewed || undefined,
        nextReview: existing.nextReview || undefined,
        reviewCount: existing.reviewCount,
      };
    }

    // Calculate next review date (1 day for bucket 1)
    const nextReview = new Date();
    nextReview.setDate(nextReview.getDate() + 1);

    const wordbankEntry = await prisma.wordbank.create({
      data: {
        userId,
        termId,
        status: "LEARNING",
        bucket: 1,
        nextReview,
        reviewCount: 0,
      },
    });

    console.log(`✅ Added to wordbank: ${wordbankEntry.id}`);
    return {
      id: wordbankEntry.id,
      userId: wordbankEntry.userId,
      termId: wordbankEntry.termId,
      status: wordbankEntry.status,
      bucket: wordbankEntry.bucket,
      lastReviewed: wordbankEntry.lastReviewed || undefined,
      nextReview: wordbankEntry.nextReview || undefined,
      reviewCount: wordbankEntry.reviewCount,
    };
  } catch (error) {
    console.error(`❌ Failed to add to wordbank:`, error);
    throw error;
  }
}

/**
 * Get the next daily word for a user based on spaced repetition
 */
export async function getNextDailyWord(userId: string): Promise<any> {
  console.log(`🎯 Getting next daily word for user ${userId}`);

  try {
    // First, check for words due for review
    const dueForReview = await prisma.wordbank.findMany({
      where: {
        userId,
        nextReview: {
          lte: new Date(),
        },
        status: {
          in: ["LEARNING", "REVIEWING"],
        },
        relevance: "RELATED",
      },
      include: {
        term: {
          include: {
            topic: true,
          },
        },
      },
      orderBy: {
        nextReview: "asc",
      },
      take: 1,
    });

    if (dueForReview.length > 0) {
      console.log(`📖 Found word due for review: ${dueForReview[0].term.term}`);
      return {
        type: "review",
        wordbank: dueForReview[0],
        term: dueForReview[0].term,
      };
    }

    // If no reviews due, get a new word from user's topics
    const userTopics = await prisma.userTopic.findMany({
      where: { userId, enabled: true },
      include: { topic: true },
    });

    if (userTopics.length === 0) {
      console.log(`⚠️ No topics found for user ${userId}`);
      return null;
    }

    // Get terms from user's topics that aren't already in wordbank
    const topicIds = userTopics.map((ut) => ut.topicId);
    const existingTermIds = await prisma.wordbank.findMany({
      where: { userId },
      select: { termId: true },
    });
    const existingTermIdSet = new Set(existingTermIds.map((w) => w.termId));

    const availableTerms = await prisma.term.findMany({
      where: {
        topicId: { in: topicIds },
        moderationStatus: "APPROVED",
        id: { notIn: Array.from(existingTermIdSet) },
      },
      include: { topic: true },
      orderBy: { confidenceScore: "desc" },
      take: 10,
    });

    if (availableTerms.length > 0) {
      // Pick a random term from available ones
      const randomIndex = Math.floor(Math.random() * availableTerms.length);
      const selectedTerm = availableTerms[randomIndex];

      console.log(`🆕 Selected new term: ${selectedTerm.term}`);
      return {
        type: "new",
        term: selectedTerm,
      };
    }

    console.log(`⚠️ No available terms for user ${userId}`);
    return null;
  } catch (error) {
    console.error(`❌ Failed to get next daily word:`, error);
    throw error;
  }
}

/**
 * Update wordbank entry after user review
 */
export async function updateWordbankAfterReview(
  wordbankId: string,
  action: "FAVORITE" | "LEARN_AGAIN" | "MASTERED",
): Promise<void> {
  console.log(`📝 Updating wordbank ${wordbankId} after review: ${action}`);

  try {
    const wordbank = await prisma.wordbank.findUnique({
      where: { id: wordbankId },
    });

    if (!wordbank) {
      throw new Error(`Wordbank entry not found: ${wordbankId}`);
    }

    let newBucket = wordbank.bucket;
    let newStatus = wordbank.status;
    let nextReview = new Date();

    switch (action) {
      case "LEARN_AGAIN":
        // Move back to bucket 1, review tomorrow
        newBucket = 1;
        nextReview.setDate(nextReview.getDate() + 1);
        break;

      case "FAVORITE":
        // Keep same bucket, but mark as reviewed
        nextReview.setDate(nextReview.getDate() + Math.pow(2, newBucket));
        break;

      case "MASTERED":
        // Mark as mastered, no more reviews needed
        newStatus = "MASTERED";
        nextReview = null as any; // Will be handled in the update
        break;
    }

    const updateData: any = {
      bucket: newBucket,
      status: newStatus,
      lastReviewed: new Date(),
      reviewCount: wordbank.reviewCount + 1,
    };

    if (action !== "MASTERED") {
      updateData.nextReview = nextReview;
    } else {
      updateData.nextReview = null;
    }

    await prisma.wordbank.update({
      where: { id: wordbankId },
      data: updateData,
    });

    console.log(
      `✅ Wordbank updated: bucket ${newBucket}, status ${newStatus}`,
    );
  } catch (error) {
    console.error(`❌ Failed to update wordbank:`, error);
    throw error;
  }
}
