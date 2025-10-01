import express from "express";
import { prisma } from "../utils/prisma";
import { logGeneration } from "../services/generationLogService";

const router = express.Router();

router.put("/user/:userId/terms/:termId/relevance", async (req, res) => {
  const { userId, termId } = req.params;
  const { related } = req.body as { related: boolean };

  try {
    if (related) {
      await prisma.wordbank.upsert({
        where: { userId_termId: { userId, termId } },
        update: {
          status: "LEARNING",
          relevance: "RELATED",
        },
        create: {
          userId,
          termId,
          status: "LEARNING",
          relevance: "RELATED",
          bucket: 1,
          nextReview: new Date(Date.now() + 24 * 60 * 60 * 1000),
        },
      });
    } else {
      await prisma.wordbank.updateMany({
        where: { userId, termId },
        data: {
          status: "ARCHIVED",
          relevance: "UNRELATED",
        },
      });
    }

    await logGeneration({
      userId,
      termId,
      promptType: "USER_ACTION",
      model: "user_action",
      success: true,
      metadata: { action: related ? "relate_term" : "unrelate_term" },
    });

    res.json({ success: true, related });
  } catch (error) {
    console.error("Failed to update term relevance:", error);
    res.status(500).json({ error: "Failed to update term relevance" });
  }
});

router.get("/user/:userId/terms/unrelated", async (req, res) => {
  const { userId } = req.params;

  try {
    const unrelatedTerms = await prisma.wordbank.findMany({
      where: {
        userId,
        relevance: "UNRELATED",
        status: "ARCHIVED",
      },
      include: {
        term: {
          include: { topic: true },
        },
      },
      orderBy: { lastReviewed: "desc" },
    });

    res.json({
      success: true,
      terms: unrelatedTerms.map((entry) => ({
        id: entry.term?.id ?? entry.termId,
        term: entry.term?.term ?? "",
        definition: entry.term?.definition ?? "",
        topic: entry.term?.topic?.name ?? "Unknown",
      })),
    });
  } catch (error) {
    console.error("Failed to fetch unrelated terms:", error);
    res.status(500).json({ error: "Failed to fetch unrelated terms" });
  }
});

router.post("/user/:userId/terms/:termId/reactivate", async (req, res) => {
  const { userId, termId } = req.params;

  try {
    await prisma.wordbank.updateMany({
      where: { userId, termId },
      data: {
        status: "LEARNING",
        relevance: "RELATED",
        bucket: 1,
        nextReview: new Date(Date.now() + 24 * 60 * 60 * 1000),
      },
    });

    await logGeneration({
      userId,
      termId,
      promptType: "USER_ACTION",
      model: "user_action",
      success: true,
      metadata: { action: "reactivate_term" },
    });

    res.json({ success: true });
  } catch (error) {
    console.error("Failed to reactivate term:", error);
    res.status(500).json({ error: "Failed to reactivate term" });
  }
});

export default router;
