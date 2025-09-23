export interface ContextualPromptParams {
  topic: string;
  context: string;
  numTerms: number;
  definitionStyle: 'casual' | 'formal' | 'technical' | 'academic';
  audienceLevel: 'beginner' | 'intermediate' | 'advanced';
  language: string;
}

// Specialized prompts for specific contexts
export const buildContextualPrompt = (params: ContextualPromptParams): string => {
  const { topic, context, numTerms, definitionStyle, audienceLevel, language } = params;

  // Special handling for "The Bear" TV show
  if (topic.toLowerCase().includes('bear') && context.toLowerCase().includes('tv show')) {
    return buildBearShowPrompt(params);
  }

  // Special handling for cooking/culinary topics
  if (context.toLowerCase().includes('cooking') || context.toLowerCase().includes('culinary') || 
      context.toLowerCase().includes('restaurant') || context.toLowerCase().includes('kitchen')) {
    return buildCulinaryPrompt(params);
  }

  // Default contextual prompt
  return buildDefaultContextualPrompt(params);
};

const buildBearShowPrompt = (params: ContextualPromptParams): string => {
  const { topic, numTerms, definitionStyle, audienceLevel } = params;

  return `You are an expert vocabulary coach specializing in television and culinary education. Generate professional vocabulary terms related to "${topic}" (the acclaimed TV show about a Chicago sandwich shop).

CRITICAL REQUIREMENTS:
1. Focus on PROFESSIONAL culinary and restaurant industry terms
2. NO vulgar language, inappropriate slang, or offensive content
3. NO HTML markup, technical strings, or raw data
4. Provide REAL, contextual example sentences from restaurant/kitchen environments
5. All content must be suitable for educational use
6. Maintain professional tone appropriate for culinary education

CONTENT GUIDELINES:
- Definition Style: ${definitionStyle}
- Audience Level: ${audienceLevel}
- Focus on: Professional kitchen operations, restaurant management, culinary techniques
- Context: The Bear TV show and real restaurant industry practices

Generate ${numTerms} vocabulary terms related to "${topic}" with these specifications:

PARAMETERS:
- Definition length: 2-3 sentences
- Examples per term: 2 realistic sentences from restaurant/kitchen contexts
- Include synonyms: Yes (professional alternatives)
- Include etymology: Yes (when relevant)
- Include related terms: Yes (kitchen hierarchy, techniques, equipment)

RESPONSE FORMAT:
Respond with ONLY valid JSON:

\`\`\`json
{
  "terms": [
    {
      "term": "Professional Culinary Term",
      "definition": "A clear, professional definition explaining this term in the context of restaurant kitchens and culinary operations.",
      "examples": [
        "Realistic sentence showing the term used in a professional kitchen setting.",
        "Another realistic sentence demonstrating proper usage in restaurant operations."
      ],
      "synonyms": ["professional synonym 1", "professional synonym 2"],
      "relatedTerms": ["related kitchen concept 1", "related kitchen concept 2"],
      "etymology": "Clear explanation of word origin when relevant"
    }
  ],
  "facts": [
    "Interesting fact about professional kitchens and restaurant operations.",
    "Educational fact about culinary techniques and industry practices."
  ]
}
\`\`\`

QUALITY CHECKLIST:
✓ All definitions focus on professional culinary/restaurant contexts
✓ All examples are realistic kitchen/restaurant scenarios
✓ No vulgar language or inappropriate content
✓ No HTML markup or technical strings
✓ Content is educational and professional
✓ Terms are relevant to restaurant industry
✓ Tone is appropriate for culinary education

Generate the vocabulary now:`;
};

const buildCulinaryPrompt = (params: ContextualPromptParams): string => {
  const { topic, numTerms, definitionStyle, audienceLevel } = params;

  return `You are an expert culinary educator. Generate professional vocabulary terms related to "${topic}" in culinary contexts.

CRITICAL REQUIREMENTS:
1. Focus on PROFESSIONAL culinary terminology
2. NO vulgar language or inappropriate content
3. NO HTML markup or technical strings
4. Provide REAL, contextual example sentences from culinary environments
5. All content must be suitable for culinary education
6. Maintain professional tone appropriate for cooking education

Generate ${numTerms} professional culinary terms related to "${topic}" with realistic examples from kitchen environments.

Respond with valid JSON format as specified in the Bear show prompt.`;
};

const buildDefaultContextualPrompt = (params: ContextualPromptParams): string => {
  const { topic, context, numTerms, definitionStyle, audienceLevel } = params;

  return `You are an expert vocabulary coach. Generate professional vocabulary terms related to "${topic}" in the context of "${context}".

CRITICAL REQUIREMENTS:
1. Generate ONLY clean, professional content appropriate for educational use
2. NO vulgar language, slang, or inappropriate content
3. NO HTML markup, technical strings, or raw data in definitions
4. Provide REAL, contextual example sentences (not placeholders)
5. Ensure all content is factually accurate and relevant to the topic
6. Maintain consistent professional tone throughout

Generate ${numTerms} vocabulary terms related to "${topic}" with professional definitions and realistic examples.

Respond with valid JSON format as specified in the Bear show prompt.`;
};

// Content validation specifically for contextual content
export const validateContextualContent = (content: any, context: string): { isValid: boolean; errors: string[] } => {
  const errors: string[] = [];

  if (!content.terms || !Array.isArray(content.terms)) {
    errors.push('Missing or invalid terms array');
    return { isValid: false, errors };
  }

  content.terms.forEach((term: any, index: number) => {
    if (!term.term || typeof term.term !== 'string') {
      errors.push(`Term ${index + 1}: Missing or invalid term name`);
    }
    
    if (!term.definition || typeof term.definition !== 'string') {
      errors.push(`Term ${index + 1}: Missing or invalid definition`);
    } else {
      // Context-specific validation
      if (context.toLowerCase().includes('bear') || context.toLowerCase().includes('tv show')) {
        // For The Bear show, ensure culinary/professional context
        const definition = term.definition.toLowerCase();
        if (definition.includes('derogatory') || definition.includes('slang') || 
            definition.includes('vulgar') || definition.includes('inappropriate')) {
          errors.push(`Term ${index + 1}: Definition contains inappropriate content for TV show context`);
        }
      }

      // General validation
      if (term.definition.includes('<') || term.definition.includes('span class')) {
        errors.push(`Term ${index + 1}: Definition contains HTML markup`);
      }
      if (term.definition.toLowerCase().includes('example usage of')) {
        errors.push(`Term ${index + 1}: Definition contains placeholder text`);
      }
    }

    // Validate examples
    if (!term.examples || !Array.isArray(term.examples)) {
      errors.push(`Term ${index + 1}: Missing or invalid examples`);
    } else {
      term.examples.forEach((example: string, exampleIndex: number) => {
        if (typeof example !== 'string' || example.toLowerCase().includes('example usage of')) {
          errors.push(`Term ${index + 1}, Example ${exampleIndex + 1}: Contains placeholder text`);
        }
      });
    }
  });

  return { isValid: errors.length === 0, errors };
};



