import { SourceAdapter, Doc } from '../types/base';
import { SourceMetadata } from '../types/miner';
import { backoffRetry } from '../utils/backoff';
import { normalizeText } from '../utils/normalize';

interface RedditSearchResponse {
  data: {
    children: Array<{
      data: RedditPost;
    }>;
    after?: string;
  };
}

interface RedditPost {
  id: string;
  title: string;
  selftext: string;
  url: string;
  permalink: string;
  subreddit: string;
  author: string;
  score: number;
  upvote_ratio: number;
  num_comments: number;
  created_utc: number;
  over_18: boolean;
  is_self: boolean;
  domain: string;
  post_hint?: string;
}

interface RedditCommentsResponse {
  data: {
    children: Array<{
      data: RedditComment;
    }>;
  };
}

interface RedditComment {
  id: string;
  body: string;
  author: string;
  score: number;
  created_utc: number;
  replies?: {
    data: {
      children: Array<{
        data: RedditComment;
      }>;
    };
  };
}

interface RedditAccessTokenResponse {
  access_token: string;
  token_type: string;
  expires_in: number;
  scope: string;
}

/**
 * Reddit API Adapter
 * Uses Reddit API v1 with OAuth2 for content discovery and fetching
 */
export class RedditAdapter implements SourceAdapter {
  private readonly clientId: string;
  private readonly clientSecret: string;
  private readonly userAgent: string;
  private accessToken: string | null = null;
  private tokenExpiresAt: number = 0;

  constructor(clientId?: string, clientSecret?: string) {
    this.clientId = clientId || process.env.REDDIT_CLIENT_ID || '';
    this.clientSecret = clientSecret || process.env.REDDIT_CLIENT_SECRET || '';
    this.userAgent = process.env.REDDIT_USER_AGENT || 'Larry-VocabApp/1.0 by /u/YourUsername';
    
    if (!this.clientId || !this.clientSecret) {
      console.warn('[REDDIT] No API credentials provided. Reddit adapter will not function.');
    }
  }

  async discover(topic: string, maxResults = 25): Promise<SourceMetadata[]> {
    if (!this.clientId || !this.clientSecret) {
      console.warn('[REDDIT] No API credentials available for discovery');
      return [];
    }

    try {
      console.log(`[REDDIT] Discovering posts for topic: ${topic}`);
      
      await this.ensureValidToken();
      
      if (!this.accessToken) {
        throw new Error('Failed to obtain access token');
      }

      // Search across all of Reddit for the topic
      const searchUrl = new URL('https://oauth.reddit.com/search');
      searchUrl.searchParams.set('q', topic);
      searchUrl.searchParams.set('type', 'link');
      searchUrl.searchParams.set('sort', 'relevance');
      searchUrl.searchParams.set('limit', Math.min(maxResults, 100).toString());
      searchUrl.searchParams.set('restrict_sr', 'false'); // Search all subreddits
      searchUrl.searchParams.set('include_over_18', 'false'); // Exclude NSFW content

      const response = await backoffRetry(async () => {
        const res = await fetch(searchUrl.toString(), {
          headers: {
            'Authorization': `Bearer ${this.accessToken}`,
            'User-Agent': this.userAgent,
          },
        });

        if (!res.ok) {
          const errorBody = await res.text();
          throw new Error(`Reddit API error: ${res.status} ${res.statusText} - ${errorBody}`);
        }

        return res.json() as Promise<RedditSearchResponse>;
      });

      if (!response.data || !response.data.children) {
        console.log(`[REDDIT] No posts found for topic: ${topic}`);
        return [];
      }

      const sources: SourceMetadata[] = response.data.children
        .map(child => child.data)
        .filter(post => 
          !post.over_18 && // No NSFW content
          post.is_self && // Text posts only
          post.selftext && // Must have content
          post.selftext.length > 50 && // Minimum content length
          post.score > 5 // Minimum quality threshold
        )
        .map(post => ({
          url: `https://reddit.com${post.permalink}`,
          title: post.title,
          snippet: this.truncateText(post.selftext, 200),
          publishedAt: new Date(post.created_utc * 1000),
          source: 'reddit',
          type: 'text' as const,
          reliability: this.calculateReliability(post),
          industry: this.categorizeIndustry(post.title, post.selftext, post.subreddit),
          metadata: {
            postId: post.id,
            subreddit: post.subreddit,
            author: post.author,
            score: post.score,
            upvoteRatio: post.upvote_ratio,
            commentCount: post.num_comments,
            wordCount: this.estimateWordCount(post.selftext),
          },
        }));

      console.log(`[REDDIT] Found ${sources.length} posts for topic: ${topic}`);
      return sources;
    } catch (error) {
      console.error(`[REDDIT] Discovery failed for topic "${topic}":`, error);
      return [];
    }
  }

  async fetch(url: string, context?: string): Promise<Doc | null> {
    if (!this.accessToken && !await this.ensureValidToken()) {
      console.warn('[REDDIT] No valid access token for fetching');
      return null;
    }

    try {
      console.log(`[REDDIT] Fetching content from: ${url}`);
      
      const postId = this.extractPostId(url);
      if (!postId) {
        throw new Error('Could not extract post ID from URL');
      }

      // Get post details with comments
      const apiUrl = `https://oauth.reddit.com/comments/${postId}`;
      
      const response = await backoffRetry(async () => {
        const res = await fetch(apiUrl, {
          headers: {
            'Authorization': `Bearer ${this.accessToken}`,
            'User-Agent': this.userAgent,
          },
        });

        if (!res.ok) {
          throw new Error(`Reddit API error: ${res.status} ${res.statusText}`);
        }

        return res.json() as Promise<[RedditSearchResponse, RedditCommentsResponse]>;
      });

      const [postData, commentsData] = response;
      
      if (!postData.data.children || postData.data.children.length === 0) {
        console.warn(`[REDDIT] Post not found: ${postId}`);
        return null;
      }

      const post = postData.data.children[0].data;
      
      if (!post.selftext || post.selftext.length < 50) {
        console.warn(`[REDDIT] Insufficient content in post: ${postId}`);
        return null;
      }

      // Extract high-quality comments
      const topComments = this.extractTopComments(commentsData, 5);
      
      const combinedContent = [
        post.title,
        post.selftext,
        ...(topComments.length > 0 ? ['Comments:', ...topComments] : [])
      ].join('\n\n');

      const doc: Doc = {
        url,
        title: post.title,
        content: normalizeText(combinedContent),
        contentHash: this.generateContentHash(combinedContent),
        source: 'reddit',
        sourceReliability: this.calculateReliability(post),
        sourceIndustry: this.categorizeIndustry(post.title, post.selftext, post.subreddit),
        extractedAt: new Date(),
        publishedAt: new Date(post.created_utc * 1000),
        metadata: {
          postId: post.id,
          subreddit: post.subreddit,
          author: post.author,
          score: post.score,
          upvoteRatio: post.upvote_ratio,
          commentCount: post.num_comments,
          topCommentsIncluded: topComments.length,
          wordCount: this.estimateWordCount(combinedContent),
        },
      };

      console.log(`[REDDIT] Successfully fetched: ${post.title} (${doc.metadata.wordCount} words)`);
      return doc;
    } catch (error) {
      console.error(`[REDDIT] Fetch failed for URL "${url}":`, error);
      return null;
    }
  }

  private async ensureValidToken(): Promise<boolean> {
    if (this.accessToken && Date.now() < this.tokenExpiresAt) {
      return true;
    }

    try {
      console.log('[REDDIT] Obtaining access token...');
      
      const credentials = Buffer.from(`${this.clientId}:${this.clientSecret}`).toString('base64');
      
      const response = await fetch('https://www.reddit.com/api/v1/access_token', {
        method: 'POST',
        headers: {
          'Authorization': `Basic ${credentials}`,
          'User-Agent': this.userAgent,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
          grant_type: 'client_credentials',
        }),
      });

      if (!response.ok) {
        const errorBody = await response.text();
        throw new Error(`Reddit OAuth error: ${response.status} ${response.statusText} - ${errorBody}`);
      }

      const tokenData = await response.json() as RedditAccessTokenResponse;
      
      this.accessToken = tokenData.access_token;
      this.tokenExpiresAt = Date.now() + (tokenData.expires_in - 60) * 1000; // 1 minute buffer
      
      console.log('[REDDIT] Access token obtained successfully');
      return true;
    } catch (error) {
      console.error('[REDDIT] Failed to obtain access token:', error);
      this.accessToken = null;
      return false;
    }
  }

  private extractPostId(url: string): string | null {
    const patterns = [
      /reddit\.com\/r\/[^\/]+\/comments\/([^\/]+)/,
      /reddit\.com\/comments\/([^\/]+)/,
      /redd\.it\/([^\/]+)/,
    ];

    for (const pattern of patterns) {
      const match = url.match(pattern);
      if (match) {
        return match[1];
      }
    }

    return null;
  }

  private extractTopComments(commentsData: RedditCommentsResponse, maxComments: number): string[] {
    if (!commentsData.data || !commentsData.data.children) {
      return [];
    }

    return commentsData.data.children
      .map(child => child.data)
      .filter(comment => 
        comment.body && 
        comment.body !== '[deleted]' && 
        comment.body !== '[removed]' &&
        comment.body.length > 20 &&
        comment.score > 2
      )
      .sort((a, b) => b.score - a.score)
      .slice(0, maxComments)
      .map(comment => comment.body);
  }

  private calculateReliability(post: RedditPost): number {
    let reliability = 0.4; // Base reliability for Reddit content

    // Adjust based on score
    if (post.score > 100) reliability += 0.3;
    else if (post.score > 50) reliability += 0.2;
    else if (post.score > 10) reliability += 0.1;
    else if (post.score < 0) reliability -= 0.2;

    // Adjust based on upvote ratio
    if (post.upvote_ratio > 0.9) reliability += 0.2;
    else if (post.upvote_ratio > 0.8) reliability += 0.1;
    else if (post.upvote_ratio < 0.6) reliability -= 0.1;

    // Adjust based on engagement
    const engagementRatio = post.num_comments / Math.max(post.score, 1);
    if (engagementRatio > 0.1) reliability += 0.1;

    // Consider subreddit quality (simplified)
    const qualitySubreddits = ['askscience', 'explainlikeimfive', 'todayilearned', 'science', 'technology'];
    if (qualitySubreddits.includes(post.subreddit.toLowerCase())) {
      reliability += 0.2;
    }

    return Math.max(0.1, Math.min(0.8, reliability));
  }

  private categorizeIndustry(title: string, content: string, subreddit: string): string {
    const text = `${title} ${content} ${subreddit}`.toLowerCase();
    
    // Subreddit-based categorization
    const subredditMappings: { [key: string]: string } = {
      'technology': 'technology',
      'programming': 'technology', 
      'science': 'science',
      'askscience': 'science',
      'finance': 'finance',
      'investing': 'finance',
      'personalfinance': 'finance',
      'fitness': 'health',
      'nutrition': 'health',
      'medicine': 'health',
      'education': 'education',
      'explainlikeimfive': 'education',
      'todayilearned': 'education',
      'art': 'arts',
      'music': 'arts',
      'books': 'arts',
      'history': 'history',
      'worldnews': 'news',
      'politics': 'news',
    };

    const subredditLower = subreddit.toLowerCase();
    if (subredditMappings[subredditLower]) {
      return subredditMappings[subredditLower];
    }

    // Content-based categorization
    const industries = {
      'technology': ['tech', 'programming', 'software', 'computer', 'coding', 'algorithm'],
      'science': ['science', 'research', 'study', 'experiment', 'discovery', 'theory'],
      'finance': ['money', 'investment', 'stock', 'trading', 'economics', 'financial'],
      'health': ['health', 'medical', 'fitness', 'exercise', 'nutrition', 'wellness'],
      'education': ['learn', 'teach', 'education', 'school', 'university', 'course'],
      'arts': ['art', 'music', 'creative', 'design', 'culture', 'literature'],
      'news': ['news', 'current', 'politics', 'government', 'policy', 'breaking'],
    };

    for (const [industry, keywords] of Object.entries(industries)) {
      if (keywords.some(keyword => text.includes(keyword))) {
        return industry;
      }
    }

    return 'general';
  }

  private truncateText(text: string, maxLength: number): string {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - 3) + '...';
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
export function createRedditAdapter(clientId?: string, clientSecret?: string): RedditAdapter {
  return new RedditAdapter(clientId, clientSecret);
}
