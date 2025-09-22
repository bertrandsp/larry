import { SourceAdapter, Doc } from '../types/base';
import { SourceMetadata } from '../types/miner';
import { backoffRetry } from '../utils/backoff';
import { normalizeText } from '../utils/normalize';

interface StackOverflowSearchResponse {
  items: Array<{
    question_id: number;
    title: string;
    body: string;
    creation_date: number;
    last_activity_date: number;
    score: number;
    view_count: number;
    answer_count: number;
    tags: string[];
    owner: {
      display_name?: string;
      reputation?: number;
    };
    is_answered: boolean;
    accepted_answer_id?: number;
  }>;
  has_more: boolean;
  quota_max: number;
  quota_remaining: number;
}

interface StackOverflowAnswersResponse {
  items: Array<{
    answer_id: number;
    question_id: number;
    body: string;
    creation_date: number;
    score: number;
    is_accepted: boolean;
    owner: {
      display_name?: string;
      reputation?: number;
    };
  }>;
}

/**
 * Stack Overflow API Adapter
 * Uses Stack Exchange API for technical Q&A content discovery
 */
export class StackOverflowAdapter implements SourceAdapter {
  private readonly baseUrl = 'https://api.stackexchange.com/2.3';
  private readonly site = 'stackoverflow';
  private readonly userAgent = 'Larry-VocabApp/1.0';

  async discover(topic: string, maxResults = 10): Promise<SourceMetadata[]> {
    try {
      console.log(`[STACKOVERFLOW] Discovering Q&A for topic: ${topic}`);
      
      const searchUrl = new URL(`${this.baseUrl}/search/advanced`);
      searchUrl.searchParams.set('order', 'desc');
      searchUrl.searchParams.set('sort', 'relevance');
      searchUrl.searchParams.set('q', topic);
      searchUrl.searchParams.set('site', this.site);
      searchUrl.searchParams.set('pagesize', Math.min(maxResults, 100).toString());
      searchUrl.searchParams.set('filter', 'withbody'); // Include question body
      searchUrl.searchParams.set('min_score', '5'); // Quality threshold
      searchUrl.searchParams.set('accepted', 'True'); // Only questions with accepted answers

      const response = await backoffRetry(async () => {
        const res = await fetch(searchUrl.toString(), {
          headers: {
            'User-Agent': this.userAgent,
            'Accept': 'application/json',
          },
        });

        if (!res.ok) {
          throw new Error(`Stack Overflow API error: ${res.status} ${res.statusText}`);
        }

        return res.json() as Promise<StackOverflowSearchResponse>;
      });

      if (!response.items || response.items.length === 0) {
        console.log(`[STACKOVERFLOW] No Q&A found for topic: ${topic}`);
        return [];
      }

      // Filter and sort by quality
      const qualityQuestions = response.items
        .filter(q => 
          q.is_answered && // Must have answers
          q.score >= 5 && // Minimum score
          q.view_count >= 100 && // Minimum views
          q.body && q.body.length > 100 && // Substantial content
          this.isRelevantTopic(q.title, q.body, q.tags, topic)
        )
        .sort((a, b) => {
          // Prioritize by composite quality score
          const scoreA = this.calculateQualityScore(a);
          const scoreB = this.calculateQualityScore(b);
          return scoreB - scoreA;
        });

      const sources: SourceMetadata[] = qualityQuestions.map(question => ({
        url: `https://stackoverflow.com/questions/${question.question_id}`,
        title: question.title,
        snippet: this.extractSnippet(question.body),
        publishedAt: new Date(question.creation_date * 1000),
        source: 'stackoverflow',
        type: 'text' as const,
        reliability: this.calculateReliability(question),
        industry: this.categorizeIndustry(question.tags, question.title, question.body),
        metadata: {
          questionId: question.question_id.toString(),
          score: question.score,
          viewCount: question.view_count,
          answerCount: question.answer_count,
          tags: question.tags.slice(0, 8), // Limit tags
          authorReputation: question.owner.reputation || 0,
          isAnswered: question.is_answered,
          wordCount: this.estimateWordCount(question.body),
        },
      }));

      console.log(`[STACKOVERFLOW] Found ${sources.length} quality Q&A for topic: ${topic}`);
      return sources;
    } catch (error) {
      console.error(`[STACKOVERFLOW] Discovery failed for topic "${topic}":`, error);
      return [];
    }
  }

  async fetch(url: string, context?: string): Promise<Doc | null> {
    try {
      console.log(`[STACKOVERFLOW] Fetching Q&A from: ${url}`);
      
      const questionId = this.extractQuestionId(url);
      if (!questionId) {
        throw new Error('Could not extract question ID from URL');
      }

      // Get question details
      const questionUrl = new URL(`${this.baseUrl}/questions/${questionId}`);
      questionUrl.searchParams.set('site', this.site);
      questionUrl.searchParams.set('filter', 'withbody');

      const questionResponse = await backoffRetry(async () => {
        const res = await fetch(questionUrl.toString(), {
          headers: {
            'User-Agent': this.userAgent,
            'Accept': 'application/json',
          },
        });

        if (!res.ok) {
          throw new Error(`Stack Overflow API error: ${res.status} ${res.statusText}`);
        }

        return res.json() as Promise<StackOverflowSearchResponse>;
      });

      if (!questionResponse.items || questionResponse.items.length === 0) {
        console.warn(`[STACKOVERFLOW] Question not found: ${questionId}`);
        return null;
      }

      const question = questionResponse.items[0];

      // Get answers for this question
      const answersUrl = new URL(`${this.baseUrl}/questions/${questionId}/answers`);
      answersUrl.searchParams.set('site', this.site);
      answersUrl.searchParams.set('filter', 'withbody');
      answersUrl.searchParams.set('order', 'desc');
      answersUrl.searchParams.set('sort', 'votes');
      answersUrl.searchParams.set('pagesize', '5'); // Top 5 answers

      const answersResponse = await backoffRetry(async () => {
        const res = await fetch(answersUrl.toString(), {
          headers: {
            'User-Agent': this.userAgent,
            'Accept': 'application/json',
          },
        });

        if (!res.ok) {
          throw new Error(`Stack Overflow API error: ${res.status} ${res.statusText}`);
        }

        return res.json() as Promise<StackOverflowAnswersResponse>;
      });

      // Process and combine content
      const answers = answersResponse.items || [];
      const topAnswers = answers
        .filter(a => a.score >= 0 && a.body && a.body.length > 50)
        .sort((a, b) => {
          // Prioritize accepted answer, then by score
          if (a.is_accepted && !b.is_accepted) return -1;
          if (!a.is_accepted && b.is_accepted) return 1;
          return b.score - a.score;
        })
        .slice(0, 3); // Top 3 answers

      // Clean and combine content
      const questionContent = this.cleanStackOverflowContent(question.body);
      const answerContents = topAnswers.map(a => this.cleanStackOverflowContent(a.body));

      const combinedContent = [
        `Question: ${question.title}`,
        '',
        questionContent,
        '',
        ...(answerContents.length > 0 ? ['Answers:', '', ...answerContents] : [])
      ].join('\n');

      if (combinedContent.length < 200) {
        console.warn(`[STACKOVERFLOW] Insufficient content for: ${questionId}`);
        return null;
      }

      const doc: Doc = {
        url,
        title: question.title,
        content: normalizeText(combinedContent),
        contentHash: this.generateContentHash(combinedContent),
        source: 'stackoverflow',
        sourceReliability: this.calculateReliability(question),
        sourceIndustry: this.categorizeIndustry(question.tags, question.title, question.body),
        extractedAt: new Date(),
        publishedAt: new Date(question.creation_date * 1000),
        metadata: {
          questionId: question.question_id.toString(),
          score: question.score,
          viewCount: question.view_count,
          answerCount: question.answer_count,
          tags: question.tags,
          topAnswersIncluded: topAnswers.length,
          authorReputation: question.owner.reputation || 0,
          wordCount: this.estimateWordCount(combinedContent),
        },
      };

      console.log(`[STACKOVERFLOW] Successfully fetched: ${question.title} (${doc.metadata.wordCount} words)`);
      return doc;
    } catch (error) {
      console.error(`[STACKOVERFLOW] Fetch failed for URL "${url}":`, error);
      return null;
    }
  }

  private extractQuestionId(url: string): string | null {
    const patterns = [
      /stackoverflow\.com\/questions\/(\d+)/,
      /stackoverflow\.com\/q\/(\d+)/,
    ];

    for (const pattern of patterns) {
      const match = url.match(pattern);
      if (match) {
        return match[1];
      }
    }

    return null;
  }

  private isRelevantTopic(title: string, body: string, tags: string[], topic: string): boolean {
    const searchTerm = topic.toLowerCase();
    const content = `${title} ${body} ${tags.join(' ')}`.toLowerCase();
    
    // Check for direct topic matches
    if (content.includes(searchTerm)) {
      return true;
    }

    // Check for related technical terms
    const relatedTerms = this.getRelatedTerms(searchTerm);
    return relatedTerms.some(term => content.includes(term));
  }

  private getRelatedTerms(topic: string): string[] {
    const relations: { [key: string]: string[] } = {
      'javascript': ['js', 'node', 'react', 'vue', 'angular', 'typescript'],
      'python': ['django', 'flask', 'pandas', 'numpy', 'machine learning'],
      'java': ['spring', 'hibernate', 'android', 'maven', 'gradle'],
      'database': ['sql', 'mysql', 'postgresql', 'mongodb', 'nosql'],
      'api': ['rest', 'graphql', 'endpoint', 'swagger', 'postman'],
      'algorithm': ['sorting', 'searching', 'complexity', 'optimization'],
      'machine learning': ['ai', 'neural', 'tensorflow', 'pytorch', 'sklearn'],
    };

    const lowerTopic = topic.toLowerCase();
    for (const [key, terms] of Object.entries(relations)) {
      if (lowerTopic.includes(key)) {
        return terms;
      }
    }

    return [];
  }

  private calculateQualityScore(question: StackOverflowSearchResponse['items'][0]): number {
    let score = question.score * 0.4; // Base score weight
    score += Math.log10(question.view_count + 1) * 0.3; // View count (logarithmic)
    score += question.answer_count * 0.2; // Answer count
    score += (question.owner.reputation || 0) / 10000 * 0.1; // Author reputation

    return score;
  }

  private calculateReliability(question: StackOverflowSearchResponse['items'][0]): number {
    let reliability = 0.6; // Base reliability for Stack Overflow

    // Adjust based on community validation
    if (question.score > 20) reliability += 0.2;
    else if (question.score > 10) reliability += 0.1;
    else if (question.score < 0) reliability -= 0.3;

    // Adjust based on answer quality
    if (question.is_answered && question.answer_count > 2) reliability += 0.1;
    if (question.accepted_answer_id) reliability += 0.1;

    // Adjust based on author reputation
    const reputation = question.owner.reputation || 0;
    if (reputation > 10000) reliability += 0.1;
    else if (reputation > 1000) reliability += 0.05;

    // Adjust based on community engagement
    if (question.view_count > 10000) reliability += 0.1;

    return Math.max(0.2, Math.min(0.9, reliability));
  }

  private categorizeIndustry(tags: string[], title: string, body: string): string {
    const content = `${tags.join(' ')} ${title} ${body}`.toLowerCase();
    
    const industries = {
      'web-development': ['javascript', 'html', 'css', 'react', 'vue', 'angular', 'frontend', 'backend'],
      'mobile-development': ['android', 'ios', 'swift', 'kotlin', 'react-native', 'flutter'],
      'data-science': ['python', 'r', 'pandas', 'numpy', 'scikit-learn', 'data', 'analytics'],
      'machine-learning': ['ml', 'ai', 'tensorflow', 'pytorch', 'neural', 'deep-learning'],
      'database': ['sql', 'mysql', 'postgresql', 'mongodb', 'database', 'query'],
      'devops': ['docker', 'kubernetes', 'aws', 'azure', 'deployment', 'ci/cd'],
      'security': ['security', 'encryption', 'authentication', 'vulnerability', 'ssl'],
      'algorithms': ['algorithm', 'data-structure', 'complexity', 'sorting', 'searching'],
    };

    for (const [industry, keywords] of Object.entries(industries)) {
      if (keywords.some(keyword => content.includes(keyword))) {
        return industry;
      }
    }

    return 'programming';
  }

  private cleanStackOverflowContent(html: string): string {
    // Remove code blocks and HTML tags, keep readable text
    return html
      .replace(/<pre><code>[\s\S]*?<\/code><\/pre>/g, '[CODE_BLOCK]') // Replace code blocks
      .replace(/<code>([^<]+)<\/code>/g, '`$1`') // Inline code
      .replace(/<[^>]*>/g, ' ') // Remove HTML tags
      .replace(/&[^;]+;/g, ' ') // Remove HTML entities
      .replace(/\s+/g, ' ') // Normalize whitespace
      .trim();
  }

  private extractSnippet(body: string, maxLength = 200): string {
    const cleaned = this.cleanStackOverflowContent(body);
    if (cleaned.length <= maxLength) return cleaned;
    return cleaned.substring(0, maxLength - 3) + '...';
  }

  private estimateWordCount(text: string): number {
    return text.split(/\s+/).filter(word => word.length > 0).length;
  }

  private generateContentHash(content: string): string {
    let hash = 0;
    for (let i = 0; i < content.length; i++) {
      const char = content.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return Math.abs(hash).toString(36);
  }
}

// Factory function for easy instantiation
export function createStackOverflowAdapter(): StackOverflowAdapter {
  return new StackOverflowAdapter();
}
