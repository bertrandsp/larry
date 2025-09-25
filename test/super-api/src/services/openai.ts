import { OpenAI } from 'openai';

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

export interface VocabularyTerm {
  term: string;
  definition: string;
  examples: string[];
  pronunciation?: string;
  etymology?: string;
  synonyms?: string[];
  antonyms?: string[];
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  category: string;
}

export interface VocabularyResponse {
  terms: VocabularyTerm[];
  topic: string;
  metadata: {
    model: string;
    timestamp: string;
  };
}

export async function generateVocabulary(
  topic: string,
  numTerms: number = 1,
  difficulty: 'beginner' | 'intermediate' | 'advanced' = 'intermediate'
): Promise<VocabularyResponse> {
  console.log(`🤖 Generating ${numTerms} ${difficulty} terms for topic: ${topic}`);

  const prompt = `Generate ${numTerms} vocabulary terms related to "${topic}" at ${difficulty} level.

For each term, provide:
- term: the vocabulary word
- definition: clear, concise definition
- examples: 2-3 example sentences using the term
- pronunciation: phonetic pronunciation (optional)
- etymology: word origin (optional)
- synonyms: 2-3 similar words (optional)
- antonyms: 2-3 opposite words (optional)
- difficulty: ${difficulty}
- category: subject category (e.g., "technology", "science", "business")

Return as JSON with this exact structure:
{
  "terms": [
    {
      "term": "example",
      "definition": "a thing characteristic of its kind",
      "examples": ["This is a perfect example.", "Let me give you an example."],
      "pronunciation": "ig-ZAM-pul",
      "etymology": "from Latin exemplum",
      "synonyms": ["instance", "illustration", "sample"],
      "antonyms": ["exception", "anomaly"],
      "difficulty": "${difficulty}",
      "category": "general"
    }
  ]
}`;

  try {
    const completion = await openai.chat.completions.create({
      model: "gpt-4o",
      messages: [
        {
          role: "system",
          content: "You are a vocabulary expert. Always respond with valid JSON in the exact format requested."
        },
        {
          role: "user",
          content: prompt
        }
      ],
      temperature: 0.7,
      max_tokens: 2000,
      response_format: { type: "json_object" }
    });

    const content = completion.choices[0].message.content;
    if (!content) {
      throw new Error('No content received from OpenAI');
    }

    const result = JSON.parse(content);
    
    return {
      terms: result.terms,
      topic,
      metadata: {
        model: completion.model,
        timestamp: new Date().toISOString()
      }
    };

  } catch (error) {
    console.error('❌ Error generating vocabulary:', error);
    throw new Error(`Failed to generate vocabulary: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
}

export async function testOpenAI(): Promise<boolean> {
  try {
    const response = await openai.chat.completions.create({
      model: "gpt-4o",
      messages: [{ role: "user", content: "Say 'OpenAI connection working!'" }],
      max_tokens: 10
    });
    
    return response.choices[0].message.content?.includes('working') || false;
  } catch (error) {
    console.error('OpenAI test failed:', error);
    return false;
  }
}
