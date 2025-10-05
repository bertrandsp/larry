import { OpenAI } from "openai";
import { logOpenAiUsage } from "../metrics/logEvents";

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
  timeout: 30000,
});

export interface OptimizedOpenAiUsage {
  model: string;
  inputTokens: number;
  outputTokens: number;
  totalTokens: number;
  cost: number;
  duration: number;
}

// Optimized model selection based on complexity
export function selectOptimalModel(
  complexity: 'basic' | 'intermediate' | 'advanced',
  userTier: string = 'free'
): string {
  // Use gpt-4o-mini for most cases (90% cost reduction)
  if (complexity === 'basic' || userTier === 'free' || userTier === 'basic') {
    return 'gpt-4o-mini';
  }
  
  // Only use gpt-4o for advanced enterprise users
  if (complexity === 'advanced' && userTier === 'enterprise') {
    return 'gpt-4o';
  }
  
  return 'gpt-4o-mini'; // Default to cheaper model
}

// Optimized prompt builder - much shorter and focused
export function buildOptimizedPrompt(
  topic: string,
  numTerms: number,
  complexity: 'basic' | 'intermediate' | 'advanced'
): string {
  const levelInstructions = {
    basic: "Use simple, everyday terms that beginners would know.",
    intermediate: "Mix basic and some specialized terms for enthusiasts.",
    advanced: "Use professional, expert-level terminology."
  };

  return `Generate ${numTerms} vocabulary terms for "${topic}".

Level: ${levelInstructions[complexity]}

Return JSON:
{
  "terms": [
    {
      "term": "word",
      "definition": "Simple 1-2 sentence definition",
      "examples": ["Example 1", "Example 2"]
    }
  ]
}`;
}

// Optimized vocabulary generation
export async function generateOptimizedVocabulary(
  topic: string,
  numTerms: number = 5,
  complexity: 'basic' | 'intermediate' | 'advanced' = 'basic',
  userTier: string = 'free',
  jobId?: string
): Promise<{ response: any; usage: OptimizedOpenAiUsage }> {
  const startTime = Date.now();
  const model = selectOptimalModel(complexity, userTier);
  const prompt = buildOptimizedPrompt(topic, numTerms, complexity);

  try {
    const completion = await openai.chat.completions.create({
      model,
      messages: [
        {
          role: "system",
          content: "You are a vocabulary coach. Respond with valid JSON only.",
        },
        {
          role: "user",
          content: prompt,
        },
      ],
      temperature: 0.7,
      max_tokens: Math.min(numTerms * 100, 1000), // Optimize token usage
      response_format: { type: "json_object" },
    });

    const endTime = Date.now();
    const duration = endTime - startTime;
    const usage = completion.usage;

    const usageData: OptimizedOpenAiUsage = {
      model: completion.model,
      inputTokens: usage?.prompt_tokens || 0,
      outputTokens: usage?.completion_tokens || 0,
      totalTokens: usage?.total_tokens || 0,
      cost: calculateOptimizedCost(completion.model, usage?.prompt_tokens || 0, usage?.completion_tokens || 0),
      duration,
    };

    // Log usage
    if (jobId) {
      await logOpenAiUsage(
        "optimized_vocabulary_generation",
        usageData.model,
        usageData.inputTokens,
        usageData.outputTokens,
        undefined,
        {
          jobId,
          totalTokens: usageData.totalTokens,
          cost: usageData.cost,
          duration: usageData.duration,
          optimization: 'model_selection_and_prompt_reduction'
        }
      );
    }

    const content = completion.choices[0]?.message?.content;
    if (!content) {
      throw new Error("No content received from OpenAI");
    }

    return {
      response: JSON.parse(content),
      usage: usageData
    };

  } catch (error) {
    const endTime = Date.now();
    const duration = endTime - startTime;
    
    console.error("Optimized OpenAI generation failed:", error);
    throw new Error(`OpenAI generation failed: ${error instanceof Error ? error.message : "Unknown error"}`);
  }
}

// Accurate cost calculation with separate input/output pricing
function calculateOptimizedCost(model: string, inputTokens: number, outputTokens: number): number {
  const pricing = {
    "gpt-4o": {
      input: 0.005,
      output: 0.015,
    },
    "gpt-4o-mini": {
      input: 0.00015,
      output: 0.0006,
    },
  };

  const modelPricing = pricing[model as keyof typeof pricing] || pricing["gpt-4o-mini"];
  
  return (
    (inputTokens / 1000) * modelPricing.input +
    (outputTokens / 1000) * modelPricing.output
  );
}

// Caching layer for repeated requests
const cache = new Map<string, { data: any; timestamp: number; ttl: number }>();

export function getCachedResponse(key: string): any | null {
  const cached = cache.get(key);
  if (!cached) return null;
  
  if (Date.now() - cached.timestamp > cached.ttl) {
    cache.delete(key);
    return null;
  }
  
  return cached.data;
}

export function setCachedResponse(key: string, data: any, ttlMs: number = 3600000): void {
  cache.set(key, {
    data,
    timestamp: Date.now(),
    ttl: ttlMs
  });
}

// Generate cache key for requests
export function generateCacheKey(topic: string, numTerms: number, complexity: string): string {
  return `vocab:${topic.toLowerCase()}:${numTerms}:${complexity}`;
}

// Optimized generation with caching
export async function generateWithCache(
  topic: string,
  numTerms: number = 5,
  complexity: 'basic' | 'intermediate' | 'advanced' = 'basic',
  userTier: string = 'free',
  jobId?: string
): Promise<{ response: any; usage: OptimizedOpenAiUsage; cached: boolean }> {
  const cacheKey = generateCacheKey(topic, numTerms, complexity);
  const cached = getCachedResponse(cacheKey);
  
  if (cached) {
    console.log(`🎯 Cache hit for ${topic} (${numTerms} terms, ${complexity})`);
    return {
      response: cached,
      usage: {
        model: 'cached',
        inputTokens: 0,
        outputTokens: 0,
        totalTokens: 0,
        cost: 0,
        duration: 0
      },
      cached: true
    };
  }

  const result = await generateOptimizedVocabulary(topic, numTerms, complexity, userTier, jobId);
  
  // Cache for 1 hour
  setCachedResponse(cacheKey, result.response, 3600000);
  
  return {
    ...result,
    cached: false
  };
}

// Rate limiting per user
const userRequestCounts = new Map<string, { count: number; resetTime: number }>();

export function checkRateLimit(userId: string, tier: string = 'free'): boolean {
  const limits = {
    free: 3,    // 3 requests per hour
    basic: 10,  // 10 requests per hour
    premium: 25, // 25 requests per hour
    enterprise: 50 // 50 requests per hour
  };

  const limit = limits[tier as keyof typeof limits] || limits.free;
  const now = Date.now();
  const userData = userRequestCounts.get(userId);

  if (!userData || now > userData.resetTime) {
    userRequestCounts.set(userId, { count: 1, resetTime: now + 3600000 }); // 1 hour
    return true;
  }

  if (userData.count >= limit) {
    return false;
  }

  userData.count++;
  return true;
}
