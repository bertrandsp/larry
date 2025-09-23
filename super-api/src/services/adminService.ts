import { Request, Response } from 'express';
import { prisma } from '../utils/prisma';
import { adminLogger } from '../utils/logger';
import { logModerationEvent } from '../metrics/logEvents';
import { incrementModerationAction, setModerationQueueSize } from '../metrics/metrics';

/**
 * Get all flagged terms that need admin review
 * Flags terms with low confidence scores or pending moderation status
 */
export async function getFlaggedTerms(req: Request, res: Response) {
  try {
    const { page = 1, limit = 50, status } = req.query;
    const skip = (Number(page) - 1) * Number(limit);

    // Build where clause for flagged terms
    const whereClause: any = {
      OR: [
        { confidenceScore: { lt: 0.5 } }, // Low confidence terms
        { moderationStatus: 'pending' },   // Pending review
      ]
    };

    // Add status filter if provided
    if (status && ['pending', 'approved', 'rejected'].includes(status as string)) {
      whereClause.moderationStatus = status;
    }

    const terms = await prisma.term.findMany({
      where: whereClause,
      include: {
        topic: {
          select: {
            id: true,
            name: true
          }
        }
      },
      orderBy: [
        { confidenceScore: 'asc' }, // Lowest confidence first
        { updatedAt: 'desc' }
      ],
      skip,
      take: Number(limit)
    });

    const total = await prisma.term.count({ where: whereClause });

    res.json({
      terms,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total,
        pages: Math.ceil(total / Number(limit))
      }
    });
  } catch (error: any) {
    console.error('Error fetching flagged terms:', error);
    res.status(500).json({ error: 'Failed to fetch flagged terms' });
  }
}

/**
 * Get all terms with pagination and filtering
 */
export async function getAllTerms(req: Request, res: Response) {
  try {
    const { page = 1, limit = 100, status, topicId, search } = req.query;
    const skip = (Number(page) - 1) * Number(limit);

    // Build where clause
    const whereClause: any = {};

    if (status && ['pending', 'approved', 'rejected'].includes(status as string)) {
      whereClause.moderationStatus = status;
    }

    if (topicId) {
      whereClause.topicId = topicId;
    }

    if (search) {
      whereClause.OR = [
        { term: { contains: search as string, mode: 'insensitive' } },
        { definition: { contains: search as string, mode: 'insensitive' } }
      ];
    }

    const terms = await prisma.term.findMany({
      where: whereClause,
      include: {
        topic: {
          select: {
            id: true,
            name: true
          }
        }
      },
      orderBy: { updatedAt: 'desc' },
      skip,
      take: Number(limit)
    });

    const total = await prisma.term.count({ where: whereClause });

    res.json({
      terms,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total,
        pages: Math.ceil(total / Number(limit))
      }
    });
  } catch (error: any) {
    console.error('Error fetching all terms:', error);
    res.status(500).json({ error: 'Failed to fetch terms' });
  }
}

/**
 * Update term moderation status and definition
 */
export async function updateTermModeration(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const { definition, status, note } = req.body;

    // Validate required fields
    if (!status || !['pending', 'approved', 'rejected'].includes(status)) {
      return res.status(400).json({ 
        error: 'Invalid status. Must be pending, approved, or rejected' 
      });
    }

    // Check if term exists
    const existingTerm = await prisma.term.findUnique({
      where: { id },
      include: { topic: true }
    });

    if (!existingTerm) {
      return res.status(404).json({ error: 'Term not found' });
    }

    // Update the term
    const updatedTerm = await prisma.term.update({
      where: { id },
      data: {
        definition: definition || existingTerm.definition,
        moderationStatus: status,
        moderationNote: note || null,
        updatedByAdmin: true,
        updatedAt: new Date()
      },
      include: {
        topic: {
          select: {
            id: true,
            name: true
          }
        }
      }
    });

    // Log the moderation action
    adminLogger.info('Term moderated', {
      termId: id,
      term: updatedTerm.term,
      status,
      note,
      topicId: updatedTerm.topicId
    });

    // Log to metrics
    await logModerationEvent(status, id, updatedTerm.topicId, { note });
    incrementModerationAction(status as 'approve' | 'reject', 'success');

    res.json({
      success: true,
      term: updatedTerm,
      message: `Term ${status} successfully`
    });
  } catch (error: any) {
    console.error('Error updating term moderation:', error);
    res.status(500).json({ error: 'Failed to update term moderation' });
  }
}

/**
 * Get moderation statistics
 */
export async function getModerationStats(req: Request, res: Response) {
  try {
    const [
      totalTerms,
      pendingTerms,
      approvedTerms,
      rejectedTerms,
      lowConfidenceTerms,
      adminUpdatedTerms
    ] = await Promise.all([
      prisma.term.count(),
      prisma.term.count({ where: { moderationStatus: 'pending' } }),
      prisma.term.count({ where: { moderationStatus: 'approved' } }),
      prisma.term.count({ where: { moderationStatus: 'rejected' } }),
      prisma.term.count({ where: { confidenceScore: { lt: 0.5 } } }),
      prisma.term.count({ where: { updatedByAdmin: true } })
    ]);

    // Update moderation queue size metric
    setModerationQueueSize(pendingTerms);

    const stats = {
      totalTerms,
      pendingTerms,
      approvedTerms,
      rejectedTerms,
      lowConfidenceTerms,
      adminUpdatedTerms,
      approvalRate: totalTerms > 0 ? (approvedTerms / totalTerms * 100).toFixed(1) : 0
    };

    adminLogger.info('Moderation stats retrieved', stats);

    res.json(stats);
  } catch (error: any) {
    console.error('Error fetching moderation stats:', error);
    res.status(500).json({ error: 'Failed to fetch moderation statistics' });
  }
}

/**
 * Bulk moderate multiple terms
 */
export async function bulkModerateTerms(req: Request, res: Response) {
  try {
    const { termIds, status, note } = req.body;

    if (!Array.isArray(termIds) || termIds.length === 0) {
      return res.status(400).json({ error: 'termIds must be a non-empty array' });
    }

    if (!status || !['pending', 'approved', 'rejected'].includes(status)) {
      return res.status(400).json({ 
        error: 'Invalid status. Must be pending, approved, or rejected' 
      });
    }

    // Update all terms
    const result = await prisma.term.updateMany({
      where: {
        id: { in: termIds }
      },
      data: {
        moderationStatus: status,
        moderationNote: note || null,
        updatedByAdmin: true,
        updatedAt: new Date()
      }
    });

    console.log(`🔧 Admin bulk moderated ${result.count} terms to ${status}`);

    res.json({
      success: true,
      updatedCount: result.count,
      message: `Successfully moderated ${result.count} terms to ${status}`
    });
  } catch (error: any) {
    console.error('Error bulk moderating terms:', error);
    res.status(500).json({ error: 'Failed to bulk moderate terms' });
  }
}
