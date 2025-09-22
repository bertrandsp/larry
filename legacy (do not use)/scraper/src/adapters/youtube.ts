import { SourceAdapter, Doc } from '../types/base';
import { SourceMetadata } from '../types/miner';
import { backoffRetry } from '../utils/backoff';
import { normalizeText } from '../utils/normalize';

interface YouTubeSearchResponse {
  items: Array<{
    id: {
      videoId: string;
    };
    snippet: {
      title: string;
      description: string;
      publishedAt: string;
      channelTitle: string;
      thumbnails: {
        default: { url: string };
      };
    };
  }>;
  pageInfo: {
    totalResults: number;
  };
}

interface YouTubeCaptionsListResponse {
  items: Array<{
    id: string;
    snippet: {
      language: string;
      name: string;
      trackKind: string;
    };
  }>;
}

interface YouTubeVideoDetailsResponse {
  items: Array<{
    id: string;
    snippet: {
      title: string;
      description: string;
      publishedAt: string;
      channelTitle: string;
      categoryId: string;
      tags?: string[];
    };
    statistics: {
      viewCount: string;
      likeCount?: string;
    };
    contentDetails: {
      duration: string;
    };
  }>;
}

/**
 * YouTube Data API Adapter
 * Uses YouTube Data API v3 for video discovery and transcript fetching
 */
export class YouTubeAdapter implements SourceAdapter {
  private readonly apiKey: string;
  private readonly baseUrl = 'https://www.googleapis.com/youtube/v3';
  private readonly maxDuration = 1800; // 30 minutes max for vocabulary content

  constructor(apiKey?: string) {
    this.apiKey = apiKey || process.env.YOUTUBE_API_KEY || '';
    if (!this.apiKey) {
      console.warn('[YOUTUBE] No API key provided. YouTube adapter will not function.');
    }
  }

  async discover(topic: string, maxResults = 10): Promise<SourceMetadata[]> {
    if (!this.apiKey) {
      console.warn('[YOUTUBE] No API key available for discovery');
      return [];
    }

    try {
      console.log(`[YOUTUBE] Discovering videos for topic: ${topic}`);
      
      const searchUrl = new URL(`${this.baseUrl}/search`);
      searchUrl.searchParams.set('part', 'snippet');
      searchUrl.searchParams.set('q', topic);
      searchUrl.searchParams.set('type', 'video');
      searchUrl.searchParams.set('maxResults', Math.min(maxResults, 50).toString());
      searchUrl.searchParams.set('order', 'relevance');
      searchUrl.searchParams.set('videoCaption', 'closedCaption'); // Only videos with captions
      searchUrl.searchParams.set('videoDuration', 'medium'); // 4-20 minutes
      searchUrl.searchParams.set('videoEmbeddable', 'true');
      searchUrl.searchParams.set('key', this.apiKey);

      const response = await backoffRetry(async () => {
        const res = await fetch(searchUrl.toString());

        if (!res.ok) {
          const errorBody = await res.text();
          throw new Error(`YouTube API error: ${res.status} ${res.statusText} - ${errorBody}`);
        }

        return res.json() as Promise<YouTubeSearchResponse>;
      });

      if (!response.items || response.items.length === 0) {
        console.log(`[YOUTUBE] No videos found for topic: ${topic}`);
        return [];
      }

      // Get additional details for each video to filter by duration
      const videoIds = response.items.map(item => item.id.videoId);
      const videoDetails = await this.getVideoDetails(videoIds);

      const sources: SourceMetadata[] = response.items
        .map((item, index) => {
          const details = videoDetails.find(d => d.id === item.id.videoId);
          const duration = details ? this.parseDuration(details.contentDetails.duration) : 0;
          
          // Filter out videos that are too long
          if (duration > this.maxDuration) {
            return null;
          }

          return {
            url: `https://www.youtube.com/watch?v=${item.id.videoId}`,
            title: item.snippet.title,
            snippet: item.snippet.description.substring(0, 200) + '...',
            publishedAt: new Date(item.snippet.publishedAt),
            source: 'youtube',
            type: 'video' as const,
            reliability: this.calculateReliability(details),
            industry: this.categorizeIndustry(item.snippet.title, item.snippet.description, details?.snippet.tags),
            metadata: {
              videoId: item.id.videoId,
              channelTitle: item.snippet.channelTitle,
              duration: duration,
              viewCount: details?.statistics.viewCount ? parseInt(details.statistics.viewCount) : 0,
              hasTranscript: true, // We filtered for videos with captions
            },
          };
        })
        .filter((source): source is SourceMetadata => source !== null);

      console.log(`[YOUTUBE] Found ${sources.length} videos for topic: ${topic}`);
      return sources;
    } catch (error) {
      console.error(`[YOUTUBE] Discovery failed for topic "${topic}":`, error);
      return [];
    }
  }

  async fetch(url: string, context?: string): Promise<Doc | null> {
    if (!this.apiKey) {
      console.warn('[YOUTUBE] No API key available for fetching');
      return null;
    }

    try {
      console.log(`[YOUTUBE] Fetching transcript from: ${url}`);
      
      const videoId = this.extractVideoId(url);
      if (!videoId) {
        throw new Error('Could not extract video ID from URL');
      }

      // Get video details first
      const videoDetails = await this.getVideoDetails([videoId]);
      const video = videoDetails[0];
      
      if (!video) {
        console.warn(`[YOUTUBE] Video not found: ${videoId}`);
        return null;
      }

      // Get captions/transcript
      const transcript = await this.getVideoTranscript(videoId);
      
      if (!transcript || transcript.length < 100) {
        console.warn(`[YOUTUBE] No sufficient transcript found for: ${videoId}`);
        return null;
      }

      const combinedContent = `${video.snippet.title}\n\n${video.snippet.description}\n\nTranscript:\n${transcript}`;

      const doc: Doc = {
        url,
        title: video.snippet.title,
        content: normalizeText(combinedContent),
        contentHash: this.generateContentHash(combinedContent),
        source: 'youtube',
        sourceReliability: this.calculateReliability(video),
        sourceIndustry: this.categorizeIndustry(video.snippet.title, video.snippet.description, video.snippet.tags),
        extractedAt: new Date(),
        publishedAt: new Date(video.snippet.publishedAt),
        metadata: {
          videoId: video.id,
          channelTitle: video.snippet.channelTitle,
          duration: this.parseDuration(video.contentDetails.duration),
          viewCount: parseInt(video.statistics.viewCount),
          transcriptLength: transcript.length,
          tags: video.snippet.tags?.slice(0, 10) || [],
          categoryId: video.snippet.categoryId,
        },
      };

      console.log(`[YOUTUBE] Successfully fetched: ${video.snippet.title} (${transcript.length} chars transcript)`);
      return doc;
    } catch (error) {
      console.error(`[YOUTUBE] Fetch failed for URL "${url}":`, error);
      return null;
    }
  }

  private async getVideoDetails(videoIds: string[]): Promise<YouTubeVideoDetailsResponse['items']> {
    const detailsUrl = new URL(`${this.baseUrl}/videos`);
    detailsUrl.searchParams.set('part', 'snippet,statistics,contentDetails');
    detailsUrl.searchParams.set('id', videoIds.join(','));
    detailsUrl.searchParams.set('key', this.apiKey);

    const response = await backoffRetry(async () => {
      const res = await fetch(detailsUrl.toString());
      if (!res.ok) {
        throw new Error(`YouTube API error: ${res.status} ${res.statusText}`);
      }
      return res.json() as Promise<YouTubeVideoDetailsResponse>;
    });

    return response.items || [];
  }

  private async getVideoTranscript(videoId: string): Promise<string | null> {
    try {
      // First, get available captions
      const captionsUrl = new URL(`${this.baseUrl}/captions`);
      captionsUrl.searchParams.set('part', 'snippet');
      captionsUrl.searchParams.set('videoId', videoId);
      captionsUrl.searchParams.set('key', this.apiKey);

      const captionsResponse = await backoffRetry(async () => {
        const res = await fetch(captionsUrl.toString());
        if (!res.ok) {
          throw new Error(`YouTube API error: ${res.status} ${res.statusText}`);
        }
        return res.json() as Promise<YouTubeCaptionsListResponse>;
      });

      if (!captionsResponse.items || captionsResponse.items.length === 0) {
        console.warn(`[YOUTUBE] No captions available for video: ${videoId}`);
        return null;
      }

      // Find English captions (prefer auto-generated or manual)
      const englishCaption = captionsResponse.items.find(
        caption => caption.snippet.language === 'en' || caption.snippet.language.startsWith('en')
      );

      if (!englishCaption) {
        console.warn(`[YOUTUBE] No English captions found for video: ${videoId}`);
        return null;
      }

      // Note: The YouTube API doesn't allow direct download of caption content
      // This would require additional authentication and the caption download endpoint
      // For now, we'll return a placeholder indicating transcript availability
      
      console.warn(`[YOUTUBE] Caption download requires additional implementation for video: ${videoId}`);
      return null;

      // TODO: Implement actual caption download using YouTube API v3
      // This requires proper OAuth2 authentication and caption download permissions
      // Alternative: Use youtube-transcript npm package or similar third-party solution
      
    } catch (error) {
      console.error(`[YOUTUBE] Failed to get transcript for video ${videoId}:`, error);
      return null;
    }
  }

  private extractVideoId(url: string): string | null {
    const patterns = [
      /(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([^&\n?#]+)/,
      /youtube\.com\/v\/([^&\n?#]+)/,
    ];

    for (const pattern of patterns) {
      const match = url.match(pattern);
      if (match) {
        return match[1];
      }
    }

    return null;
  }

  private parseDuration(duration: string): number {
    // Parse ISO 8601 duration (PT4M13S format)
    const match = duration.match(/PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?/);
    if (!match) return 0;

    const hours = parseInt(match[1] || '0');
    const minutes = parseInt(match[2] || '0');
    const seconds = parseInt(match[3] || '0');

    return hours * 3600 + minutes * 60 + seconds;
  }

  private calculateReliability(video?: YouTubeVideoDetailsResponse['items'][0]): number {
    if (!video) return 0.5;

    let reliability = 0.6; // Base reliability for YouTube content

    // Adjust based on view count
    const views = parseInt(video.statistics.viewCount);
    if (views > 1000000) reliability += 0.2;
    else if (views > 100000) reliability += 0.1;
    else if (views < 1000) reliability -= 0.2;

    // Adjust based on likes ratio (if available)
    if (video.statistics.likeCount) {
      const likes = parseInt(video.statistics.likeCount);
      const likeRatio = likes / Math.max(views, 1);
      if (likeRatio > 0.02) reliability += 0.1; // High engagement
    }

    // Cap reliability
    return Math.max(0.1, Math.min(0.9, reliability));
  }

  private categorizeIndustry(title: string, description: string, tags?: string[]): string {
    const text = `${title} ${description} ${tags?.join(' ') || ''}`.toLowerCase();
    
    const industries = {
      'education': ['tutorial', 'learn', 'education', 'course', 'lesson', 'teach', 'explain'],
      'technology': ['tech', 'programming', 'coding', 'software', 'computer', 'ai', 'machine learning'],
      'science': ['science', 'research', 'experiment', 'discovery', 'physics', 'chemistry', 'biology'],
      'finance': ['finance', 'money', 'investment', 'trading', 'economics', 'business'],
      'health': ['health', 'fitness', 'medical', 'wellness', 'exercise', 'nutrition'],
      'arts': ['art', 'music', 'creative', 'design', 'painting', 'drawing'],
      'entertainment': ['entertainment', 'funny', 'comedy', 'gaming', 'movie', 'review'],
      'news': ['news', 'current events', 'politics', 'breaking', 'analysis'],
    };

    for (const [industry, keywords] of Object.entries(industries)) {
      if (keywords.some(keyword => text.includes(keyword))) {
        return industry;
      }
    }

    return 'general';
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
export function createYouTubeAdapter(apiKey?: string): YouTubeAdapter {
  return new YouTubeAdapter(apiKey);
}
