/**
 * Universal Source Discovery System
 * 
 * Dynamically finds cutting-edge sources for ANY topic across ALL industries
 */

export interface DiscoveredSource {
  url: string;
  type: 'rss' | 'api' | 'html';
  title: string;
  description?: string;
  lastUpdated?: Date;
  reliability: number; // 0-1 score
  freshness: number;   // 0-1 score (how often content updates)
  relevance: number;   // 0-1 score (how relevant to topic)
  industry?: string;
}

/**
 * Universal source templates that work across ALL industries
 */
const UNIVERSAL_SOURCE_PATTERNS = {
  // Academic & Research
  academic: {
    arxiv: (topic: string) => ({
      url: `https://export.arxiv.org/rss/${getArxivCategory(topic)}`,
      type: 'rss' as const,
      title: `arXiv ${topic}`,
      reliability: 0.9,
      freshness: 0.8,
    }),
    pubmed: (topic: string) => ({
      url: `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/erss.cgi?rss_guid=${getPubmedGuid(topic)}`,
      type: 'rss' as const,
      title: `PubMed ${topic}`,
      reliability: 0.95,
      freshness: 0.7,
    }),
    researchgate: (topic: string) => ({
      url: `https://www.researchgate.net/topic/${encodeURIComponent(topic)}/publications`,
      type: 'html' as const,
      title: `ResearchGate ${topic}`,
      reliability: 0.8,
      freshness: 0.6,
    }),
  },

  // News & Media
  news: {
    googleNews: (topic: string) => ({
      url: `https://news.google.com/rss/search?q=${encodeURIComponent(topic)}&hl=en&gl=US&ceid=US:en`,
      type: 'rss' as const,
      title: `Google News: ${topic}`,
      reliability: 0.8,
      freshness: 0.95,
    }),
    allSides: (topic: string) => ({
      url: `https://www.allsides.com/tags/${encodeURIComponent(topic.toLowerCase())}/feed`,
      type: 'rss' as const,
      title: `AllSides ${topic}`,
      reliability: 0.85,
      freshness: 0.8,
    }),
  },

  // Technology & Innovation
  tech: {
    hackerNews: (topic: string) => ({
      url: `https://hnrss.org/newest?q=${encodeURIComponent(topic)}`,
      type: 'rss' as const,
      title: `Hacker News: ${topic}`,
      reliability: 0.8,
      freshness: 0.9,
    }),
    reddit: (topic: string) => ({
      url: `https://www.reddit.com/search.rss?q=${encodeURIComponent(topic)}&sort=new`,
      type: 'rss' as const,
      title: `Reddit: ${topic}`,
      reliability: 0.6,
      freshness: 0.95,
    }),
  },

  // Industry-Specific
  business: {
    bloomberg: (topic: string) => ({
      url: `https://feeds.bloomberg.com/keyword/${encodeURIComponent(topic)}`,
      type: 'rss' as const,
      title: `Bloomberg: ${topic}`,
      reliability: 0.9,
      freshness: 0.9,
    }),
    reuters: (topic: string) => ({
      url: `https://www.reutersagency.com/feed/?best-topics=${encodeURIComponent(topic)}`,
      type: 'rss' as const,
      title: `Reuters: ${topic}`,
      reliability: 0.9,
      freshness: 0.85,
    }),
  },

  // Government & Policy
  government: {
    federalRegister: (topic: string) => ({
      url: `https://www.federalregister.gov/documents/search.rss?conditions%5Bterm%5D=${encodeURIComponent(topic)}`,
      type: 'rss' as const,
      title: `Federal Register: ${topic}`,
      reliability: 0.95,
      freshness: 0.4,
    }),
  },

  // Specialized Industries
  healthcare: {
    medscape: (topic: string) => ({
      url: `https://www.medscape.com/rss/specialty/keyword/${encodeURIComponent(topic)}`,
      type: 'rss' as const,
      title: `Medscape: ${topic}`,
      reliability: 0.9,
      freshness: 0.7,
    }),
  },

  finance: {
    marketwatch: (topic: string) => ({
      url: `https://feeds.marketwatch.com/marketwatch/search/${encodeURIComponent(topic)}/`,
      type: 'rss' as const,
      title: `MarketWatch: ${topic}`,
      reliability: 0.85,
      freshness: 0.9,
    }),
  },

  legal: {
    justia: (topic: string) => ({
      url: `https://news.justia.com/rss/keyword/${encodeURIComponent(topic)}`,
      type: 'rss' as const,
      title: `Justia News: ${topic}`,
      reliability: 0.8,
      freshness: 0.6,
    }),
  },

  science: {
    scienceDaily: (topic: string) => ({
      url: `https://www.sciencedaily.com/rss/keyword/${encodeURIComponent(topic)}.xml`,
      type: 'rss' as const,
      title: `Science Daily: ${topic}`,
      reliability: 0.9,
      freshness: 0.8,
    }),
    nature: (topic: string) => ({
      url: `https://www.nature.com/search/rss?q=${encodeURIComponent(topic)}&order=date_desc`,
      type: 'rss' as const,
      title: `Nature: ${topic}`,
      reliability: 0.95,
      freshness: 0.7,
    }),
  },

  // Creative Industries
  design: {
    designNews: (topic: string) => ({
      url: `https://www.designnews.com/rss/keyword/${encodeURIComponent(topic)}`,
      type: 'rss' as const,
      title: `Design News: ${topic}`,
      reliability: 0.7,
      freshness: 0.6,
    }),
  },

  // Manufacturing & Engineering
  engineering: {
    engineeringNews: (topic: string) => ({
      url: `https://www.engineering.com/rss/keyword/${encodeURIComponent(topic)}`,
      type: 'rss' as const,
      title: `Engineering.com: ${topic}`,
      reliability: 0.8,
      freshness: 0.7,
    }),
  },
};

/**
 * Industry detection based on topic keywords
 */
function detectIndustries(topic: string): string[] {
  const topicLower = topic.toLowerCase();
  const industries: string[] = [];

  // Map keywords to industries
  const industryKeywords = {
    tech: ['software', 'ai', 'machine learning', 'blockchain', 'crypto', 'startup', 'app', 'api', 'cloud', 'data', 'algorithm'],
    healthcare: ['medical', 'health', 'disease', 'drug', 'treatment', 'therapy', 'clinical', 'patient', 'hospital', 'medicine'],
    finance: ['finance', 'bank', 'investment', 'stock', 'market', 'trading', 'crypto', 'money', 'economic', 'financial'],
    science: ['research', 'study', 'experiment', 'discovery', 'scientific', 'physics', 'chemistry', 'biology', 'climate'],
    business: ['business', 'corporate', 'company', 'industry', 'market', 'sales', 'revenue', 'profit', 'strategy'],
    legal: ['law', 'legal', 'court', 'justice', 'regulation', 'policy', 'legislation', 'attorney', 'judge'],
    government: ['government', 'policy', 'regulation', 'federal', 'state', 'political', 'election', 'congress'],
    engineering: ['engineering', 'mechanical', 'electrical', 'civil', 'manufacturing', 'construction', 'infrastructure'],
    design: ['design', 'creative', 'art', 'visual', 'graphic', 'user experience', 'interface', 'aesthetic'],
  };

  // Always include academic and news for universal coverage
  industries.push('academic', 'news');

  // Detect specific industries
  for (const [industry, keywords] of Object.entries(industryKeywords)) {
    if (keywords.some(keyword => topicLower.includes(keyword))) {
      industries.push(industry);
    }
  }

  return industries;
}

/**
 * Universal source discovery for ANY topic
 */
export async function discoverSources(
  topic: string,
  options: {
    maxSources?: number;
    minReliability?: number;
    prioritizeFreshness?: boolean;
    includeSpecialized?: boolean;
  } = {}
): Promise<DiscoveredSource[]> {
  const {
    maxSources = 10,
    minReliability = 0.6,
    prioritizeFreshness = true,
    includeSpecialized = true,
  } = options;

  console.log(`🔍 Discovering sources for topic: "${topic}"`);

  const sources: DiscoveredSource[] = [];
  const industries = detectIndustries(topic);

  console.log(`   📊 Detected industries: ${industries.join(', ')}`);

  // Add sources from detected industries
  for (const industry of industries) {
    const industryPatterns = UNIVERSAL_SOURCE_PATTERNS[industry as keyof typeof UNIVERSAL_SOURCE_PATTERNS];
    
    if (industryPatterns) {
      for (const [sourceName, sourceGenerator] of Object.entries(industryPatterns)) {
        try {
          const source = sourceGenerator(topic);
          sources.push({
            ...source,
            relevance: calculateTopicRelevance(topic, industry),
            industry,
          });
        } catch (error) {
          console.warn(`   ⚠️ Failed to generate ${sourceName} source:`, error);
        }
      }
    }
  }

  // Filter by reliability
  const reliableSources = sources.filter(s => s.reliability >= minReliability);

  // Score and sort sources
  const scoredSources = reliableSources.map(source => ({
    ...source,
    score: calculateSourceScore(source, prioritizeFreshness),
  })).sort((a, b) => b.score - a.score);

  const selectedSources = scoredSources.slice(0, maxSources);

  console.log(`   ✅ Found ${selectedSources.length} sources (from ${sources.length} candidates)`);
  
  return selectedSources;
}

/**
 * Calculate topic relevance to industry
 */
function calculateTopicRelevance(topic: string, industry: string): number {
  // Base relevance
  let relevance = 0.5;

  // Boost for exact industry matches
  if (topic.toLowerCase().includes(industry)) {
    relevance += 0.3;
  }

  // Universal sources always get decent relevance
  if (['academic', 'news'].includes(industry)) {
    relevance += 0.2;
  }

  return Math.min(1.0, relevance);
}

/**
 * Calculate overall source score
 */
function calculateSourceScore(
  source: DiscoveredSource & { score?: number },
  prioritizeFreshness: boolean
): number {
  const weights = prioritizeFreshness
    ? { reliability: 0.3, freshness: 0.4, relevance: 0.3 }
    : { reliability: 0.5, freshness: 0.2, relevance: 0.3 };

  return (
    source.reliability * weights.reliability +
    source.freshness * weights.freshness +
    source.relevance * weights.relevance
  );
}

/**
 * Get arXiv category for academic topics
 */
function getArxivCategory(topic: string): string {
  const topicLower = topic.toLowerCase();
  
  // Map topics to arXiv categories
  if (topicLower.includes('ai') || topicLower.includes('machine learning')) return 'cs.AI';
  if (topicLower.includes('computer') || topicLower.includes('software')) return 'cs.SE';
  if (topicLower.includes('crypto') || topicLower.includes('security')) return 'cs.CR';
  if (topicLower.includes('physics')) return 'physics';
  if (topicLower.includes('math')) return 'math';
  if (topicLower.includes('biology') || topicLower.includes('bio')) return 'q-bio';
  if (topicLower.includes('economics') || topicLower.includes('finance')) return 'econ';
  
  // Default to computer science
  return 'cs';
}

/**
 * Get PubMed GUID for medical topics
 */
function getPubmedGuid(topic: string): string {
  // This would need real PubMed RSS GUIDs
  // For now, return a placeholder that represents the search
  return `search-${encodeURIComponent(topic)}`;
}

/**
 * Get trending topics for proactive discovery
 */
export async function getTrendingTopics(industry?: string): Promise<string[]> {
  // This would integrate with trending APIs
  // For now, return some example trending topics
  const trendingByIndustry = {
    tech: ['quantum computing', 'edge AI', 'sustainable tech', '6G networks'],
    healthcare: ['personalized medicine', 'digital therapeutics', 'longevity research'],
    finance: ['DeFi protocols', 'ESG investing', 'central bank digital currencies'],
    science: ['fusion energy', 'carbon capture', 'synthetic biology'],
    business: ['hybrid work', 'supply chain resilience', 'circular economy'],
  };

  const generalTrending = [
    'artificial intelligence',
    'climate change',
    'renewable energy',
    'space exploration',
    'biotechnology',
  ];

  return industry && trendingByIndustry[industry as keyof typeof trendingByIndustry]
    ? [...trendingByIndustry[industry as keyof typeof trendingByIndustry], ...generalTrending.slice(0, 2)]
    : generalTrending;
}

/**
 * Smart source prioritization based on breaking news patterns
 */
export function prioritizeByBreakingNews(sources: DiscoveredSource[]): DiscoveredSource[] {
  return sources.map(source => {
    let priority = source.freshness;
    
    // Boost news sources during breaking events
    if (source.type === 'rss' && source.title.toLowerCase().includes('news')) {
      priority *= 1.2;
    }
    
    // Boost recent academic papers
    if (source.title.toLowerCase().includes('arxiv') || source.title.toLowerCase().includes('pubmed')) {
      priority *= 1.1;
    }
    
    return {
      ...source,
      freshness: Math.min(1.0, priority),
    };
  }).sort((a, b) => b.freshness - a.freshness);
}
