export interface VocabularyParams {
  topic: string;
  numTerms: number;
  definitionStyle: 'casual' | 'formal' | 'technical' | 'academic';
  sentenceRange: string; // e.g., "2-4"
  numExamples: number;
  numFacts: number;
  termSelectionLevel: 'beginner' | 'intermediate' | 'advanced'; // How advanced the terms themselves are
  definitionComplexityLevel: 'beginner' | 'intermediate' | 'advanced'; // How complex the explanations are
  domainContext: string;
  language: string;
  useAnalogy: boolean;
  includeSynonyms: boolean;
  includeAntonyms: boolean;
  includeRelatedTerms: boolean;
  includeEtymology: boolean;
  highlightRootWords: boolean;
  openAiFirst: boolean;
  existingTerms?: string[]; // Optional list of existing terms to avoid duplicates
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

export const buildPrompt = (params: VocabularyParams): string => {
  const {
    topic,
    numTerms,
    definitionStyle,
    sentenceRange,
    numExamples,
    numFacts,
    termSelectionLevel,
    definitionComplexityLevel,
    domainContext,
    language,
    useAnalogy,
    includeSynonyms,
    includeAntonyms,
    includeRelatedTerms,
    includeEtymology,
    highlightRootWords,
    existingTerms
  } = params;

  // Generate term selection and definition complexity instructions
  const termSelectionInstructions = getTermSelectionInstructions(termSelectionLevel);
  const definitionComplexityInstructions = getDefinitionComplexityInstructions(definitionComplexityLevel);
  
  console.log(`🔍 Building prompt with termSelectionLevel: ${termSelectionLevel}, definitionComplexityLevel: ${definitionComplexityLevel}`);
  
  // Build existing terms exclusion instruction
  const existingTermsInstruction = existingTerms && existingTerms.length > 0 
    ? `\n\n🚫 CRITICAL DUPLICATE PREVENTION - READ CAREFULLY:
There are ${existingTerms.length} existing terms already in the database for this topic.
DO NOT generate ANY term that appears in this list:

${existingTerms.slice(0, 150).join(', ')}${existingTerms.length > 150 ? `... and ${existingTerms.length - 150} more` : ''}

⚠️ IMPORTANT: Recent statistics show ~40% of generated terms are duplicates. You MUST:
1. Generate COMPLETELY DIFFERENT terms that are NOT in the list above
2. Check EVERY term you generate against the exclusion list
3. If you accidentally include a duplicate, it will be rejected and wasted
4. Focus on generating fresh, unique vocabulary that hasn't been covered yet

Generate new, creative terms that expand the topic in directions not yet explored.`
    : '';
  
  return `You are a vocabulary coach that helps users deeply understand any topic by generating a structured set of vocabulary terms and related facts.
${existingTermsInstruction}

${termSelectionLevel === 'beginner' ? `
🚨 CRITICAL SYSTEM INSTRUCTION FOR BEGINNER LEVEL:
You are in BEGINNER MODE. This means you MUST ONLY use the most basic, simple terms that a complete beginner would know. You are FORBIDDEN from using any advanced, specialized, or foreign terms. If you use any forbidden terms, your response will be completely rejected.

FOR COOKING TOPICS IN BEGINNER MODE, YOU MUST ONLY SELECT FROM:
"Boil", "Fry", "Bake", "Mix", "Stir", "Cut", "Heat", "Cook", "Wash", "Peel", "Chop", "Slice", "Pour", "Add", "Remove", "Taste", "Salt", "Pepper", "Oil", "Water", "Flour", "Sugar", "Eggs", "Milk", "Butter", "Bread", "Meat", "Vegetables", "Fruit", "Rice", "Pasta", "Soup", "Salad", "Sandwich", "Pizza", "Cake", "Cookie"

YOU ARE ABSOLUTELY FORBIDDEN FROM USING: Sauté, Saut, Julienne, Braise, Simmer, Marinate, Whisk, Blanch, Roast, Grill, Sear, Poach, Steam, or ANY other advanced cooking terms.
` : ''}

Your tone is simple, warm, and beginner-friendly. Avoid jargon unless it's explained. Be accurate, but creative with analogies and examples.

Generate vocabulary terms for the topic: "${topic}".

Parameters:
- Number of terms: ${numTerms}
- Definition style: ${definitionStyle}
- Sentence range per definition: ${sentenceRange}
- Example sentences per term: ${numExamples}
- Number of topic facts: ${numFacts}
- Term selection level: ${termSelectionLevel}
- Definition complexity level: ${definitionComplexityLevel}
- Domain: ${domainContext}
- Language: ${language}
${useAnalogy ? '- Include analogies' : ''}
${includeSynonyms ? '- Include synonyms' : ''}
${includeAntonyms ? '- Include antonyms' : ''}
${includeRelatedTerms ? '- Include related terms' : ''}
${includeEtymology ? '- Include etymology' : ''}
${highlightRootWords ? '- Highlight root words if compound' : ''}

${termSelectionInstructions}

${definitionComplexityInstructions}

CRITICAL ENFORCEMENT - FAILURE TO FOLLOW WILL RESULT IN REJECTION:
- You MUST strictly follow the term selection level requirements above
- For BEGINNER: ONLY select from the approved word lists - NO exceptions
- For INTERMEDIATE: Mix basic and some specialized terms, can include common foreign terms
- For ADVANCED: Only select professional, expert-level terminology
- DOUBLE-CHECK: Before including any term, verify it matches the selection level
- WARNING: If you include forbidden terms, the entire response will be invalid

VALIDATION CHECKLIST:
${termSelectionLevel === 'beginner' ? `
BEGINNER VALIDATION - Each term MUST be:
□ A basic English word that anyone knows
□ Simple, everyday concept related to the topic
□ NOT specialized jargon or technical terms
□ NOT foreign language terms
□ NOT professional terminology
□ Examples for different topics:
  - Sports: run, jump, ball, team, game, win, lose
  - Technology: computer, phone, internet, website, email
  - Cooking: boil, fry, bake, mix, stir, cut, heat
  - Music: song, beat, melody, instrument, guitar, piano

ABSOLUTE FORBIDDEN FOR BEGINNER:
- Specialized terminology, foreign words, technical jargon, professional terms, advanced concepts
- If you include ANY inappropriate terms for the topic and level, you have FAILED.` : ''}${termSelectionLevel === 'intermediate' ? `
INTERMEDIATE VALIDATION - Each term should be:
□ Accessible to enthusiasts but not complete beginners
□ Some specialized knowledge required
□ Can include common foreign terms
□ Mix of basic and intermediate concepts
□ Industry-standard terminology is acceptable
□ Examples: specialized techniques, common foreign terms, industry jargon` : ''}${termSelectionLevel === 'advanced' ? `
ADVANCED VALIDATION - Each term should be:
□ Professional, expert-level terminology
□ Specialized techniques and foreign language terms
□ Scientific or theoretical concepts
□ Terms only professionals would know
□ Examples: advanced techniques, scientific concepts, professional jargon, expert terminology` : ''}

Respond in the following JSON format:

\`\`\`json
{
  "terms": [
    {
      "term": "Example Term",
      "definition": "A ${definitionComplexityLevel === 'beginner' ? 'simple and easy to understand' : definitionComplexityLevel === 'intermediate' ? 'clear and informative' : 'comprehensive and technically precise'}, ${definitionStyle} definition in ${sentenceRange} sentences that explains what this term means in the context of ${topic}.",
      "examples": [
        "First example sentence showing the term in context.",
        "Second example sentence demonstrating proper usage."
      ],
      ${useAnalogy ? '"analogy": "A helpful analogy that makes this concept easier to understand.",' : ''}
      ${includeSynonyms ? '"synonyms": ["similar term 1", "similar term 2"],' : ''}
      ${includeAntonyms ? '"antonyms": ["opposite term 1", "opposite term 2"],' : ''}
      ${includeRelatedTerms ? '"relatedTerms": ["related concept 1", "related concept 2"],' : ''}
      ${includeEtymology ? '"etymology": "Origin and history of the word, with root words highlighted if applicable."' : ''}
    }
  ],
  "facts": [
    "Interesting fact about ${topic}.",
    "Another fascinating fact about ${topic}."
  ]
}
\`\`\`

Make sure the JSON is valid and properly formatted.`;
};

export const getDefaultParams = (topic: string): VocabularyParams => ({
  topic,
  numTerms: 50,
  definitionStyle: 'casual',
  sentenceRange: '2-4',
  numExamples: 2,
  numFacts: 10,
  termSelectionLevel: 'intermediate',
  definitionComplexityLevel: 'intermediate',
  domainContext: 'general',
  language: 'English',
  useAnalogy: true,
  includeSynonyms: true,
  includeAntonyms: true,
  includeRelatedTerms: true,
  includeEtymology: true,
  highlightRootWords: true,
  openAiFirst: false
});

// Function to generate term selection instructions
function getTermSelectionInstructions(termSelectionLevel: 'beginner' | 'intermediate' | 'advanced'): string {
  switch (termSelectionLevel) {
    case 'beginner':
      return `TERM SELECTION - BEGINNER LEVEL:

🎯 OBJECTIVE: Select only the most basic, fundamental terms that complete beginners would know and understand.

BEGINNER TERM CRITERIA:
- Choose simple, everyday words that anyone can understand
- Focus on basic concepts, actions, and objects related to the topic
- Avoid specialized jargon, technical terms, or foreign language words
- Select terms that are commonly used in everyday conversation
- Choose concrete, tangible concepts over abstract ones

EXAMPLES BY TOPIC TYPE:
- Sports: "run", "jump", "ball", "team", "game", "win", "lose", "practice", "score", "play"
- Technology: "computer", "phone", "internet", "website", "email", "app", "button", "screen", "click", "type"
- Cooking: "boil", "fry", "bake", "mix", "stir", "cut", "heat", "cook", "salt", "pepper"
- Music: "song", "beat", "melody", "instrument", "guitar", "piano", "sing", "listen", "rhythm", "sound"

AVOID FOR BEGINNER LEVEL:
- Specialized terminology
- Foreign language terms
- Technical jargon
- Abstract concepts
- Professional terminology
- Advanced techniques or methods`;

    case 'intermediate':
      return `TERM SELECTION - INTERMEDIATE LEVEL:
Choose terms that show some knowledge of the topic but are still accessible to enthusiasts.

INTERMEDIATE TERM CRITERIA:
- Include some specialized terms but keep them commonly understood
- Mix basic concepts with more specific techniques or methods
- Can include some foreign terms that are widely used in the field
- Include industry-standard terminology that enthusiasts would know
- Balance accessibility with technical accuracy

EXAMPLES BY TOPIC:
- Cooking: "braise", "roast", "grill", "steam", "poach", "sear", "sauté", "julienne", "dice", "mince", "marinate", "season", "garnish", "technique", "method", "recipe", "ingredients", "preparation", "temperature", "texture", "flavor", "aroma", "balance", "pairing"
- Technology: "software", "hardware", "application", "programming", "database", "server", "network", "security", "encryption", "algorithm", "interface", "platform", "framework", "API", "cloud", "backup", "synchronization", "optimization", "performance"
- Sports: "training", "technique", "strategy", "tactics", "endurance", "strength", "flexibility", "coordination", "timing", "precision", "competition", "tournament", "championship", "ranking", "statistics", "performance", "recovery", "nutrition", "equipment"

CAN INCLUDE:
- Some foreign terms commonly used in the field
- Basic specialized techniques or methods
- Industry-standard terminology
- Common equipment or tools

AVOID:
- Highly specialized professional terms
- Advanced theoretical concepts
- Rare or exotic techniques
- Expert-level terminology`;

    case 'advanced':
      return `TERM SELECTION - ADVANCED LEVEL (PROFESSIONAL TERMINOLOGY):
Choose sophisticated, professional terms that demonstrate expert-level knowledge.

ADVANCED TERM CRITERIA:
- Select terms that only professionals or serious students would know
- Include specialized techniques, foreign language terms, and technical concepts
- Focus on precise, professional terminology used by experts
- Include scientific, theoretical, or highly specialized concepts
- Use industry-specific jargon and technical vocabulary

EXAMPLES BY TOPIC:
- Cooking: "sous vide", "molecular gastronomy", "Maillard reaction", "confit", "brunoise", "mirepoix", "gastrique", "nage", "beurre blanc", "consommé", "velouté", "espagnole", "béchamel", "hollandaise", "mayonnaise", "aioli", "roux", "liaison", "clarification", "reduction", "glace", "fond", "stock", "broth", "court bouillon", "chiffonade", "batonnet", "paysanne", "tourné", "mise en place", "amuse-bouche", "canapé", "hors d'oeuvre", "entremet", "petit four", "macaron", "soufflé", "terrine", "pâté", "foie gras", "truffle", "caviar", "quenelle", "spherification", "gelification", "emulsification", "deglazing", "flambé", "caramelization", "Maillard browning", "enzymatic browning", "oxidation", "fermentation", "lacto-fermentation", "pickling", "brining", "curing", "smoking", "dry aging", "wet aging"
- Technology: "microservices", "containerization", "orchestration", "kubernetes", "docker", "devops", "ci/cd", "infrastructure as code", "terraform", "ansible", "jenkins", "gitlab", "kubernetes", "helm", "prometheus", "grafana", "elasticsearch", "kibana", "logstash", "redis", "mongodb", "postgresql", "mysql", "nosql", "graphql", "restful", "oauth", "jwt", "ldap", "saml", "oauth2", "openid connect", "rbac", "abac", "zero trust", "defense in depth", "penetration testing", "vulnerability assessment", "threat modeling", "risk assessment", "compliance", "gdpr", "hipaa", "sox", "pci dss", "iso 27001", "nist", "owasp", "cve", "cwe", "mitre att&ck", "siem", "soar", "edr", "xdr", "mdr", "soc", "incident response", "forensics", "malware analysis", "reverse engineering", "exploit development", "red team", "blue team", "purple team"
- Sports: "periodization", "tapering", "peaking", "overreaching", "overtraining", "supercompensation", "lactate threshold", "vo2 max", "anaerobic capacity", "aerobic base", "power output", "cadence", "torque", "biomechanics", "kinematics", "kinetics", "proprioception", "neuromuscular", "plyometrics", "isometric", "isotonic", "isokinetic", "eccentric", "concentric", "periodization", "macrocycle", "mesocycle", "microcycle", "tapering", "peaking", "overreaching", "overtraining", "supercompensation", "lactate threshold", "vo2 max", "anaerobic capacity", "aerobic base", "power output", "cadence", "torque", "biomechanics", "kinematics", "kinetics", "proprioception", "neuromuscular", "plyometrics", "isometric", "isotonic", "isokinetic", "eccentric", "concentric"

FOCUS ON:
- Foreign language terminology (especially French for cooking, Latin for science)
- Scientific processes and theories
- Professional techniques and methods
- Advanced equipment and tools
- Theoretical concepts and principles
- Industry-specific jargon

REMEMBER: These should be terms that only professionals, experts, or serious students would know and use.`;

    default:
      return '';
  }
}

// Function to generate definition complexity instructions
function getDefinitionComplexityInstructions(definitionComplexityLevel: 'beginner' | 'intermediate' | 'advanced'): string {
  switch (definitionComplexityLevel) {
    case 'beginner':
      return `DEFINITION COMPLEXITY - BEGINNER LEVEL:
- Use ONLY simple, everyday language that a 10-year-old could understand
- Keep definitions to 1 sentence maximum
- Focus on WHAT it is, not HOW it works
- Use simple analogies: "like a recipe", "like a teacher", "like a friend"
- Examples must be from everyday life: cooking, sports, school, pets, games
- Avoid technical jargon - explain everything in plain English
- Example: Instead of "algorithm" say "a set of instructions"`;

    case 'intermediate':
      return `DEFINITION COMPLEXITY - INTERMEDIATE LEVEL:
- Use clear language with some technical terms (but always explain them)
- Provide detailed explanations (2-3 sentences)
- Include HOW things work, not just WHAT they are
- Use industry-standard terminology when appropriate
- Examples should show practical applications in real scenarios
- Balance accessibility with technical accuracy
- Can mention processes and methodologies briefly`;

    case 'advanced':
      return `DEFINITION COMPLEXITY - ADVANCED LEVEL:
- Use precise, technical language and industry terminology freely
- Provide comprehensive, detailed explanations (3-4 sentences minimum)
- Include nuanced concepts, methodologies, and specialized knowledge
- Use professional-level vocabulary and technical concepts
- Examples should demonstrate expert-level understanding and implementation
- Include technical details, algorithms, and implementation considerations
- Focus on accuracy, depth, and technical precision`;

    default:
      return '';
  }
}

// Function to get audience-specific definition template
function getDefinitionTemplate(audienceLevel: 'beginner' | 'intermediate' | 'advanced', definitionStyle: string, sentenceRange: string, topic: string): string {
  const complexity = audienceLevel === 'beginner' ? 'simple and easy to understand' : 
                    audienceLevel === 'intermediate' ? 'clear and informative' : 
                    'comprehensive and technically precise';
  
  return `A ${complexity}, ${definitionStyle} definition in ${sentenceRange} sentences that explains what this term means in the context of ${topic}.`;
}

export const validateParams = (params: Partial<VocabularyParams>): VocabularyParams => {
  const defaults = getDefaultParams(params.topic || 'general');
  
  return {
    ...defaults,
    ...params,
    numTerms: Math.max(1, Math.min(100, params.numTerms || defaults.numTerms)),
    numExamples: Math.max(1, Math.min(5, params.numExamples || defaults.numExamples)),
    numFacts: Math.max(1, Math.min(20, params.numFacts || defaults.numFacts)),
  };
};