export interface VocabularyParams {
  topic: string;
  numTerms: number;
  definitionStyle: 'casual' | 'formal' | 'technical' | 'academic';
  sentenceRange: string; // e.g., "2-4"
  numExamples: number;
  numFacts: number;
  audienceLevel: 'beginner' | 'intermediate' | 'advanced';
  domainContext: string;
  language: string;
  useAnalogy: boolean;
  includeSynonyms: boolean;
  includeAntonyms: boolean;
  includeRelatedTerms: boolean;
  includeEtymology: boolean;
  highlightRootWords: boolean;
  openAiFirst: boolean;
}

export interface VocabularyResponse {
  terms: Array<{
    term: string;
    definition: string;
    examples: string[];
    analogy?: string;
    synonyms?: string[];
    antonyms?: string[];
    relatedTerms?: string[];
    etymology?: string;
  }>;
  facts: string[];
}

export const buildEnhancedPrompt = (params: VocabularyParams): string => {
  const {
    topic,
    numTerms,
    definitionStyle,
    sentenceRange,
    numExamples,
    numFacts,
    audienceLevel,
    domainContext,
    language,
    useAnalogy,
    includeSynonyms,
    includeAntonyms,
    includeRelatedTerms,
    includeEtymology,
    highlightRootWords
  } = params;

  // Define tone and style guidelines based on definition style
  const styleGuidelines = {
    casual: "Use everyday language that's easy to understand. Be friendly and conversational.",
    formal: "Use precise, professional language appropriate for academic or business contexts.",
    technical: "Use domain-specific terminology with clear explanations. Include technical details when relevant.",
    academic: "Use scholarly language with precise terminology. Include theoretical context when appropriate."
  };

  const audienceGuidelines = {
    beginner: "Explain concepts in simple terms. Avoid jargon unless you define it clearly.",
    intermediate: "Use some specialized vocabulary but explain complex concepts clearly.",
    advanced: "Use sophisticated vocabulary and assume familiarity with basic concepts."
  };

  return `You are an expert vocabulary coach specializing in creating high-quality educational content. Your task is to generate professional, accurate, and engaging vocabulary terms for the topic: "${topic}".

CRITICAL REQUIREMENTS:
1. Generate ONLY clean, professional content appropriate for educational use
2. NO vulgar language, slang, or inappropriate content
3. NO HTML markup, technical strings, or raw data in definitions
4. Provide REAL, contextual example sentences (not placeholders)
5. Ensure all content is factually accurate and relevant to the topic
6. Maintain consistent tone throughout

CONTENT GUIDELINES:
- Definition Style: ${styleGuidelines[definitionStyle]}
- Audience Level: ${audienceGuidelines[audienceLevel]}
- Topic Context: ${domainContext}
- Language: ${language}

Generate ${numTerms} vocabulary terms related to "${topic}" with the following specifications:

PARAMETERS:
- Definition length: ${sentenceRange} sentences
- Examples per term: ${numExamples} real, contextual sentences
- Topic facts: ${numFacts} interesting, accurate facts
- Include analogies: ${useAnalogy ? 'Yes' : 'No'}
- Include synonyms: ${includeSynonyms ? 'Yes' : 'No'}
- Include antonyms: ${includeAntonyms ? 'Yes' : 'No'}
- Include related terms: ${includeRelatedTerms ? 'Yes' : 'No'}
- Include etymology: ${includeEtymology ? 'Yes' : 'No'}

RESPONSE FORMAT:
Respond with ONLY valid JSON in this exact format:

\`\`\`json
{
  "terms": [
    {
      "term": "Term Name",
      "definition": "A clear, professional definition in ${sentenceRange} sentences that accurately explains this term in the context of ${topic}. Use ${styleGuidelines[definitionStyle].toLowerCase()}",
      "examples": [
        "A complete, realistic sentence showing the term used in context.",
        "Another complete sentence demonstrating proper usage in a different scenario."
      ]${useAnalogy ? ',\n      "analogy": "A helpful analogy that makes this concept easier to understand"' : ''}${includeSynonyms ? ',\n      "synonyms": ["relevant synonym 1", "relevant synonym 2"]' : ''}${includeAntonyms ? ',\n      "antonyms": ["opposite term 1", "opposite term 2"]' : ''}${includeRelatedTerms ? ',\n      "relatedTerms": ["related concept 1", "related concept 2"]' : ''}${includeEtymology ? ',\n      "etymology": "Clear explanation of word origin and history"' : ''}
    }
  ],
  "facts": [
    "An interesting, accurate fact about ${topic}.",
    "Another fascinating fact about ${topic}."
  ]
}
\`\`\`

QUALITY CHECKLIST:
✓ All definitions are professional and appropriate
✓ All examples are complete, realistic sentences
✓ No placeholder text or generic examples
✓ No HTML markup or technical strings
✓ Content is relevant to the topic
✓ Tone is consistent with ${definitionStyle} style
✓ Information is accurate and educational

Generate the vocabulary now:`;
};

// Enhanced prompt for single term generation
export const buildSingleTermPrompt = (
  term: string, 
  topic: string, 
  context: string,
  style: 'casual' | 'formal' | 'technical' | 'academic' = 'casual'
): string => {
  return `You are an expert vocabulary coach. Generate a professional definition for the term "${term}" in the context of "${topic}".

CONTEXT: ${context}
STYLE: ${style}

REQUIREMENTS:
1. Provide a clear, accurate definition
2. Include 2 realistic example sentences
3. Use professional language appropriate for ${style} style
4. NO vulgar language, slang, or inappropriate content
5. NO HTML markup or technical strings

Respond with ONLY valid JSON:

\`\`\`json
{
  "definition": "A clear, professional definition of ${term} in the context of ${topic}",
  "examples": [
    "A complete, realistic sentence showing ${term} used in context",
    "Another complete sentence demonstrating proper usage"
  ]
}
\`\`\``;
};

// Enhanced prompt for fact generation
export const buildFactsPrompt = (topic: string, numFacts: number): string => {
  return `You are a knowledgeable educator. Generate ${numFacts} interesting, accurate facts about "${topic}".

REQUIREMENTS:
1. All facts must be accurate and verifiable
2. Use professional, educational language
3. Make facts engaging and informative
4. NO vulgar language or inappropriate content
5. Focus on educational value

Respond with ONLY valid JSON:

\`\`\`json
{
  "facts": [
    "An interesting, accurate fact about ${topic}",
    "Another fascinating fact about ${topic}"
  ]
}
\`\`\``;
};

export const getDefaultParams = (topic: string): VocabularyParams => ({
  topic,
  numTerms: 10,
  definitionStyle: 'formal',
  sentenceRange: '2-3',
  numExamples: 2,
  numFacts: 5,
  audienceLevel: 'intermediate',
  domainContext: 'general',
  language: 'English',
  useAnalogy: true,
  includeSynonyms: true,
  includeAntonyms: false,
  includeRelatedTerms: true,
  includeEtymology: true,
  highlightRootWords: true,
  openAiFirst: false
});

export const validateParams = (params: Partial<VocabularyParams>): VocabularyParams => {
  const defaults = getDefaultParams(params.topic || 'general');
  
  return {
    ...defaults,
    ...params,
    numTerms: Math.max(1, Math.min(50, params.numTerms || defaults.numTerms)),
    numExamples: Math.max(1, Math.min(3, params.numExamples || defaults.numExamples)),
    numFacts: Math.max(1, Math.min(10, params.numFacts || defaults.numFacts)),
  };
};

// Content validation functions
export const validateGeneratedContent = (content: any): { isValid: boolean; errors: string[] } => {
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
      // Check for problematic content
      if (term.definition.includes('<') || term.definition.includes('span class')) {
        errors.push(`Term ${index + 1}: Definition contains HTML markup`);
      }
      if (term.definition.toLowerCase().includes('example usage of')) {
        errors.push(`Term ${index + 1}: Definition contains placeholder text`);
      }
    }

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

// Content sanitization
export const sanitizeContent = (content: any): any => {
  if (content.terms) {
    content.terms = content.terms.map((term: any) => ({
      ...term,
      definition: sanitizeText(term.definition),
      examples: term.examples?.map((example: string) => sanitizeText(example)) || [],
      analogy: term.analogy ? sanitizeText(term.analogy) : undefined,
      etymology: term.etymology ? sanitizeText(term.etymology) : undefined
    }));
  }

  if (content.facts) {
    content.facts = content.facts.map((fact: string) => sanitizeText(fact));
  }

  return content;
};

export const sanitizeText = (text: string): string => {
  if (typeof text !== 'string') return '';
  
  // Check if the text is mostly markup before sanitizing
  const markupRatio = (text.match(/<[^>]*>|span class|aboutmwt|typeofmw|relmw|href|title|Category|classform|use-with|classLatn|mention|wiki|Appendix|plural_number|present_tense|participle|gerund/g) || []).length;
  const totalWords = text.split(/\s+/).length;
  
  // If more than 50% of the content is markup, skip external source entirely
  if (markupRatio > totalWords * 0.5) {
    return 'Professional definition unavailable from external source';
  }
  
  // Remove HTML markup and technical strings more aggressively
  let sanitized = text
    .replace(/<[^>]*>/g, '') // Remove HTML tags
    .replace(/span class[^"]*"[^"]*"/g, '') // Remove span classes
    .replace(/aboutmwt\d+/g, '') // Remove aboutmwt references
    .replace(/typeofmw:[^"]*"/g, '') // Remove typeofmw references
    .replace(/relmw:[^"]*"/g, '') // Remove relmw references
    .replace(/href[^"]*"/g, '') // Remove href references
    .replace(/title[^"]*"/g, '') // Remove title references
    .replace(/Category:[^"]*"/g, '') // Remove category references
    .replace(/classform-of-definition[^"]*"/g, '') // Remove form-of-definition classes
    .replace(/use-with-mention[^"]*"/g, '') // Remove use-with-mention classes
    .replace(/i classLatn[^"]*"/g, '') // Remove Latn classes
    .replace(/mention langen[^"]*"/g, '') // Remove mention langen classes
    .replace(/a relmw[^"]*"/g, '') // Remove a relmw references
    .replace(/wiki[^"]*"/g, '') // Remove wiki references
    .replace(/Appendix:[^"]*"/g, '') // Remove Appendix references
    .replace(/plural_number[^"]*"/g, '') // Remove plural_number references
    .replace(/present_tense[^"]*"/g, '') // Remove present_tense references
    .replace(/participle[^"]*"/g, '') // Remove participle references
    .replace(/gerund[^"]*"/g, '') // Remove gerund references
    .replace(/\s+/g, ' ') // Normalize whitespace
    .trim();

  // If the text is still mostly markup or too short, provide a fallback
  if (sanitized.length < 15 || /^[^a-zA-Z]*$/.test(sanitized) || sanitized.split(' ').length < 3) {
    return 'Professional definition unavailable from external source';
  }

  // Replace placeholder text with more appropriate content
  if (sanitized.toLowerCase().includes('example usage of')) {
    sanitized = sanitized.replace(/example usage of [^.]*/gi, 'This term is commonly used');
  }
  
  return sanitized;
};
