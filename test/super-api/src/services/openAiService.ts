import { OpenAI } from "openai";
import { VocabularyParams, VocabularyResponse, buildPrompt } from "../promptBuilder";
import { logOpenAiUsage } from "../metrics/logEvents";

const openai = new OpenAI({ 
  apiKey: process.env.OPENAI_API_KEY 
});

export interface OpenAiUsage {
  model: string;
  inputTokens: number;
  outputTokens: number;
  totalTokens: number;
  cost: number;
  duration: number;
}

export async function generateVocabulary(
  params: VocabularyParams,
  jobId?: string
): Promise<{ response: VocabularyResponse; usage: OpenAiUsage }> {
  const startTime = Date.now();
  
  try {
    console.log(`🔍 generateVocabulary called with params:`, {
      topic: params.topic,
      termSelectionLevel: params.termSelectionLevel,
      definitionComplexityLevel: params.definitionComplexityLevel,
      numTerms: params.numTerms
    });
    const prompt = buildPrompt(params);
    
    const completion = await openai.chat.completions.create({
      model: "gpt-4o",
      messages: [
        {
          role: "system",
          content: "You are a helpful vocabulary coach. Always respond with valid JSON in the exact format requested."
        },
        {
          role: "user",
          content: prompt
        }
      ],
      temperature: 0.7,
      max_tokens: 4000,
      response_format: { type: "json_object" }
    });

    const endTime = Date.now();
    const duration = endTime - startTime;
    
    const usage = completion.usage;
    const usageData: OpenAiUsage = {
      model: completion.model,
      inputTokens: usage?.prompt_tokens || 0,
      outputTokens: usage?.completion_tokens || 0,
      totalTokens: usage?.total_tokens || 0,
      cost: calculateCost(completion.model, usage?.total_tokens || 0),
      duration
    };

    // Log OpenAI usage
    if (jobId) {
      await logOpenAiUsage(
        'vocabulary_generation',
        usageData.model,
        usageData.inputTokens,
        usageData.outputTokens,
        undefined, // topicId
        {
          jobId,
          totalTokens: usageData.totalTokens,
          cost: usageData.cost,
          duration: usageData.duration
        }
      );
    }

    const content = completion.choices[0]?.message?.content;
    if (!content) {
      throw new Error("No content received from OpenAI");
    }

    let response: VocabularyResponse;
    try {
      response = JSON.parse(content);
    } catch (parseError) {
      console.error("Failed to parse OpenAI response:", content);
      throw new Error("Invalid JSON response from OpenAI");
    }

    return { response, usage: usageData };
  } catch (error) {
    const endTime = Date.now();
    const duration = endTime - startTime;
    
    console.error("OpenAI generation failed:", error);
    throw new Error(`OpenAI generation failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
}

export async function generateSingleTerm(
  term: string,
  topic: string,
  context?: string
): Promise<{ definition: string; examples: string[]; source: string }> {
  const prompt = `Define the term "${term}" in the context of "${topic}". 
${context ? `Additional context: ${context}` : ''}

Provide:
1. A clear, concise definition (2-3 sentences)
2. Two example sentences showing proper usage
3. The source or domain this definition comes from

Respond in JSON format:
{
  "definition": "Clear definition here",
  "examples": ["Example 1", "Example 2"],
  "source": "Source domain or reference"
}`;

  try {
    const completion = await openai.chat.completions.create({
      model: "gpt-4o",
      messages: [
        {
          role: "system",
          content: "You are a helpful vocabulary assistant. Always respond with valid JSON."
        },
        {
          role: "user",
          content: prompt
        }
      ],
      temperature: 0.5,
      max_tokens: 500,
      response_format: { type: "json_object" }
    });

    const content = completion.choices[0]?.message?.content;
    if (!content) {
      throw new Error("No content received from OpenAI");
    }

    const response = JSON.parse(content);
    return {
      definition: response.definition || `Definition for ${term}`,
      examples: response.examples || [`Example usage of ${term}`],
      source: response.source || "AI Generated"
    };
  } catch (error) {
    console.error(`Failed to generate definition for ${term}:`, error);
    return {
      definition: `Definition for ${term} in the context of ${topic}`,
      examples: [`Example usage of ${term}`],
      source: "AI Generated (Fallback)"
    };
  }
}

function calculateCost(model: string, tokens: number): number {
  // GPT-4o pricing (as of 2024)
  const pricing = {
    "gpt-4o": {
      input: 0.005,  // $0.005 per 1K tokens
      output: 0.015  // $0.015 per 1K tokens
    },
    "gpt-4o-mini": {
      input: 0.00015,
      output: 0.0006
    }
  };

  const modelPricing = pricing[model as keyof typeof pricing] || pricing["gpt-4o"];
  
  // Rough estimate - in practice you'd track input/output separately
  const estimatedInputTokens = tokens * 0.7; // Assume 70% input
  const estimatedOutputTokens = tokens * 0.3; // Assume 30% output
  
  return (estimatedInputTokens / 1000 * modelPricing.input) + 
         (estimatedOutputTokens / 1000 * modelPricing.output);
}

