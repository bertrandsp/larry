import express from 'express';
import { prisma } from '../utils/prisma';

const router = express.Router();

// GET /user/:userId/terms → Return vocab list
router.get('/user/:userId/terms', async (req, res) => {
  const { userId } = req.params;

  try {
    // Ensure user exists
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) return res.status(404).json({ error: 'User not found' });

    // Step 1: Get all topic IDs linked to user
    const userTopics = await prisma.userTopic.findMany({
      where: { userId },
    });
    const topicIds = userTopics.map((ut) => ut.topicId);

    if (topicIds.length === 0) {
      return res.json([]);
    }

    // Step 2: Get all terms linked to those topics
    const terms = await prisma.term.findMany({
      where: { topicId: { in: topicIds } },
      orderBy: { confidenceScore: 'desc' }, // Optional
    });

    // Step 3: Format response
    const formatted = terms.map((term) => ({
      term: term.term,
      definition: term.definition,
      example: term.example,
      source: term.source,
      sourceUrl: term.sourceUrl,
      confidenceScore: term.confidenceScore,
      complexityLevel: term.complexityLevel,
      category: term.category,
      gptGenerated: term.gptGenerated,
    }));

    res.json(formatted);
  } catch (err: any) {
    console.error('GET /user/:userId/terms error:', err);
    res.status(500).json({ error: 'Failed to fetch terms' });
  }
});

// GET /user/terms/:topicId - Get terms for a specific topic
router.get('/user/terms/:topicId', async (req, res) => {
  try {
    const { topicId } = req.params;
    
    const terms = await prisma.term.findMany({
      where: { topicId },
      orderBy: {
        createdAt: 'desc'
      }
    });

    res.json(terms);
  } catch (error: any) {
    console.error('Error fetching topic terms:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /user/terms - Create a new term
router.post('/user/terms', async (req, res) => {
  try {
    const {
      topicId,
      term,
      definition,
      example,
      source,
      sourceUrl,
      verified = false,
      gptGenerated = false,
      confidenceScore = 0.8,
      category = 'general',
      complexityLevel = 'intermediate'
    } = req.body;

    if (!topicId || !term || !definition || !example || !source) {
      return res.status(400).json({
        error: 'topicId, term, definition, example, and source are required'
      });
    }

    const newTerm = await prisma.term.create({
      data: {
        topicId,
        term,
        definition,
        example,
        source,
        sourceUrl,
        verified,
        gptGenerated,
        confidenceScore,
        category,
        complexityLevel
      },
      include: {
        topic: true
      }
    });

    res.status(201).json(newTerm);
  } catch (error: any) {
    console.error('Error creating term:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /user/facts/:topicId - Get facts for a specific topic
router.get('/user/facts/:topicId', async (req, res) => {
  try {
    const { topicId } = req.params;
    
    const facts = await prisma.fact.findMany({
      where: { topicId },
      orderBy: {
        createdAt: 'desc'
      }
    });

    res.json(facts);
  } catch (error: any) {
    console.error('Error fetching topic facts:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /user/facts - Create a new fact
router.post('/user/facts', async (req, res) => {
  try {
    const {
      topicId,
      fact,
      source,
      sourceUrl,
      gptGenerated = false,
      category = 'general'
    } = req.body;

    if (!topicId || !fact || !source) {
      return res.status(400).json({
        error: 'topicId, fact, and source are required'
      });
    }

    const newFact = await prisma.fact.create({
      data: {
        topicId,
        fact,
        source,
        sourceUrl,
        gptGenerated,
        category
      },
      include: {
        topic: true
      }
    });

    res.status(201).json(newFact);
  } catch (error: any) {
    console.error('Error creating fact:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
