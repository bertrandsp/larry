/**
 * Recency Scoring System
 * 
 * Weights vocabulary terms based on how fresh/cutting-edge they are
 */

export interface RecencyMetadata {
  publishedAt?: Date;
  lastUpdated?: Date;
  source?: string;
  breakingNews?: boolean;
  trendingScore?: number;
}

export interface RecencyConfig {
  maxAgeHours?: number;        // Content older than this gets zero recency boost
  peakBoostMultiplier?: number; // Maximum boost for brand new content
  decayRate?: number;          // How quickly recency boost decays
  breakingNewsMultiplier?: number; // Extra boost for breaking news
  trendingBoostMultiplier?: number; // Extra boost for trending topics
}

const DEFAULT_RECENCY_CONFIG: Required<RecencyConfig> = {
  maxAgeHours: 72,              // 3 days
  peakBoostMultiplier: 2.0,     // 2x boost for brand new content
  decayRate: 0.5,               // Exponential decay
  breakingNewsMultiplier: 1.5,  // 1.5x boost for breaking news
  trendingBoostMultiplier: 1.3, // 1.3x boost for trending topics
};

/**
 * Calculate recency score for content
 * Returns a multiplier (1.0 = normal, 2.0 = double score for fresh content)
 */
export function calculateRecencyScore(
  metadata: RecencyMetadata,
  config: RecencyConfig = {}
): number {
  const cfg = { ...DEFAULT_RECENCY_CONFIG, ...config };
  
  // Get the most relevant timestamp
  const contentDate = metadata.publishedAt || metadata.lastUpdated;
  
  if (!contentDate) {
    // No date information, return baseline score
    return 1.0;
  }

  const now = new Date();
  const ageHours = (now.getTime() - contentDate.getTime()) / (1000 * 60 * 60);

  // Content older than max age gets no recency boost
  if (ageHours > cfg.maxAgeHours) {
    return 1.0;
  }

  // Calculate base recency multiplier with exponential decay
  const normalizedAge = ageHours / cfg.maxAgeHours; // 0 = brand new, 1 = max age
  const decayFactor = Math.pow(1 - normalizedAge, 1 / cfg.decayRate);
  let recencyMultiplier = 1.0 + (cfg.peakBoostMultiplier - 1.0) * decayFactor;

  // Apply breaking news boost
  if (metadata.breakingNews) {
    recencyMultiplier *= cfg.breakingNewsMultiplier;
  }

  // Apply trending boost
  if (metadata.trendingScore && metadata.trendingScore > 0.7) {
    recencyMultiplier *= cfg.trendingBoostMultiplier;
  }

  return Math.min(recencyMultiplier, cfg.peakBoostMultiplier * 2); // Cap at 4x max
}

/**
 * Determine if content should be considered "breaking news"
 */
export function isBreakingNews(
  metadata: RecencyMetadata,
  topic: string
): boolean {
  const { publishedAt, source } = metadata;
  
  if (!publishedAt) return false;

  const ageMinutes = (Date.now() - publishedAt.getTime()) / (1000 * 60);
  
  // Content must be very recent (within 2 hours)
  if (ageMinutes > 120) return false;

  // Check if source is known for breaking news
  const breakingNewsSources = [
    'reuters',
    'bloomberg',
    'associated press',
    'google news',
    'breaking news',
    'alert',
    'urgent',
  ];

  const sourceLower = (source || '').toLowerCase();
  const hasBreakingSource = breakingNewsSources.some(pattern => sourceLower.includes(pattern));

  // Check if topic contains breaking news keywords
  const topicLower = topic.toLowerCase();
  const breakingKeywords = [
    'breaking',
    'urgent',
    'alert',
    'just in',
    'developing',
    'live',
    'now',
    'today',
    'announcement',
    'released',
    'launched',
    'unveiled',
  ];

  const hasBreakingKeywords = breakingKeywords.some(keyword => topicLower.includes(keyword));

  return hasBreakingSource || hasBreakingKeywords;
}

/**
 * Calculate trending score based on content patterns
 */
export function calculateTrendingScore(
  content: string,
  metadata: RecencyMetadata
): number {
  let trendingScore = 0;

  const contentLower = content.toLowerCase();
  
  // Check for trending technology terms
  const trendingTechTerms = [
    'ai', 'artificial intelligence', 'machine learning', 'chatgpt', 'gpt-4',
    'blockchain', 'cryptocurrency', 'nft', 'metaverse', 'web3',
    'quantum', 'edge computing', '5g', '6g', 'autonomous',
    'sustainable', 'green energy', 'carbon neutral', 'climate tech',
    'biotech', 'gene therapy', 'crispr', 'mrna',
  ];

  const trendingMatches = trendingTechTerms.filter(term => contentLower.includes(term));
  trendingScore += trendingMatches.length * 0.1;

  // Check for recent funding/investment mentions
  const fundingKeywords = [
    'funding', 'investment', 'raised', 'series a', 'series b', 'ipo',
    'acquisition', 'merger', 'partnership', 'collaboration',
  ];

  const fundingMatches = fundingKeywords.filter(term => contentLower.includes(term));
  trendingScore += fundingMatches.length * 0.15;

  // Check for research/discovery indicators
  const researchKeywords = [
    'study', 'research', 'discovery', 'breakthrough', 'innovation',
    'published', 'findings', 'results', 'clinical trial',
  ];

  const researchMatches = researchKeywords.filter(term => contentLower.includes(term));
  trendingScore += researchMatches.length * 0.1;

  // Boost for very recent content
  if (metadata.publishedAt) {
    const ageHours = (Date.now() - metadata.publishedAt.getTime()) / (1000 * 60 * 60);
    if (ageHours < 6) trendingScore += 0.3;
    else if (ageHours < 24) trendingScore += 0.2;
    else if (ageHours < 48) trendingScore += 0.1;
  }

  return Math.min(1.0, trendingScore);
}

/**
 * Enhanced candidate scoring that includes recency
 */
export function scoreWithRecency(
  baseScore: number,
  content: string,
  metadata: RecencyMetadata,
  topic: string,
  config: RecencyConfig = {}
): {
  finalScore: number;
  recencyMultiplier: number;
  trendingScore: number;
  isBreaking: boolean;
} {
  // Calculate trending score
  const trendingScore = calculateTrendingScore(content, metadata);
  
  // Check if breaking news
  const isBreaking = isBreakingNews(metadata, topic);
  
  // Enhanced metadata with trending info
  const enhancedMetadata: RecencyMetadata = {
    ...metadata,
    breakingNews: isBreaking,
    trendingScore,
  };
  
  // Calculate recency multiplier
  const recencyMultiplier = calculateRecencyScore(enhancedMetadata, config);
  
  // Apply recency boost to base score
  const finalScore = baseScore * recencyMultiplier;
  
  return {
    finalScore,
    recencyMultiplier,
    trendingScore,
    isBreaking,
  };
}

/**
 * Time-based content categorization
 */
export function categorizeByFreshness(
  publishedAt: Date
): 'breaking' | 'fresh' | 'recent' | 'standard' | 'old' {
  const ageHours = (Date.now() - publishedAt.getTime()) / (1000 * 60 * 60);
  
  if (ageHours < 2) return 'breaking';      // < 2 hours
  if (ageHours < 12) return 'fresh';        // < 12 hours  
  if (ageHours < 48) return 'recent';       // < 2 days
  if (ageHours < 168) return 'standard';    // < 1 week
  return 'old';                             // > 1 week
}

/**
 * Smart content prioritization queue
 */
export interface PriorityQueueItem {
  id: string;
  content: string;
  baseScore: number;
  metadata: RecencyMetadata;
  topic: string;
  priority: 'urgent' | 'high' | 'normal' | 'low';
  processingOrder: number;
}

export function createPriorityQueue(
  items: Omit<PriorityQueueItem, 'priority' | 'processingOrder'>[]
): PriorityQueueItem[] {
  return items
    .map(item => {
      const scoringResult = scoreWithRecency(
        item.baseScore,
        item.content,
        item.metadata,
        item.topic
      );
      
      // Determine priority
      let priority: PriorityQueueItem['priority'] = 'normal';
      
      if (scoringResult.isBreaking) {
        priority = 'urgent';
      } else if (scoringResult.trendingScore > 0.7 || scoringResult.recencyMultiplier > 1.5) {
        priority = 'high';
      } else if (scoringResult.recencyMultiplier < 1.1) {
        priority = 'low';
      }
      
      return {
        ...item,
        priority,
        processingOrder: scoringResult.finalScore,
      };
    })
    .sort((a, b) => {
      // Sort by priority first, then by processing order
      const priorityOrder = { urgent: 4, high: 3, normal: 2, low: 1 };
      const priorityDiff = priorityOrder[b.priority] - priorityOrder[a.priority];
      
      if (priorityDiff !== 0) return priorityDiff;
      return b.processingOrder - a.processingOrder;
    });
}

/**
 * Real-time freshness monitoring
 */
export class FreshnessMonitor {
  private intervals: Map<string, NodeJS.Timeout> = new Map();
  
  /**
   * Monitor a source for fresh content
   */
  startMonitoring(
    sourceId: string,
    checkInterval: number, // minutes
    callback: (freshContent: any[]) => void
  ): void {
    if (this.intervals.has(sourceId)) {
      this.stopMonitoring(sourceId);
    }
    
    const interval = setInterval(async () => {
      try {
        // This would check the source for new content
        // Implementation depends on source type (RSS, API, etc.)
        console.log(`📡 Checking ${sourceId} for fresh content...`);
        
        // Placeholder for actual implementation
        const freshContent = await this.checkSourceForUpdates(sourceId);
        
        if (freshContent.length > 0) {
          console.log(`✨ Found ${freshContent.length} fresh items from ${sourceId}`);
          callback(freshContent);
        }
      } catch (error) {
        console.error(`❌ Error monitoring ${sourceId}:`, error);
      }
    }, checkInterval * 60 * 1000);
    
    this.intervals.set(sourceId, interval);
    console.log(`👀 Started monitoring ${sourceId} every ${checkInterval} minutes`);
  }
  
  /**
   * Stop monitoring a source
   */
  stopMonitoring(sourceId: string): void {
    const interval = this.intervals.get(sourceId);
    if (interval) {
      clearInterval(interval);
      this.intervals.delete(sourceId);
      console.log(`⏹️ Stopped monitoring ${sourceId}`);
    }
  }
  
  /**
   * Stop all monitoring
   */
  stopAll(): void {
    for (const [sourceId] of this.intervals) {
      this.stopMonitoring(sourceId);
    }
  }
  
  private async checkSourceForUpdates(sourceId: string): Promise<any[]> {
    // This would implement actual source checking logic
    // For now, return empty array
    return [];
  }
}
