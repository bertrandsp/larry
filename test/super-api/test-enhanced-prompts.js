const { openAiService } = require('./dist/services/openAiService');

async function testEnhancedPrompts() {
  console.log('🧪 Testing Enhanced OpenAI Prompts...\n');

  try {
    // Test 1: Generate 100 terms + 10 facts
    console.log('1. Testing generateTermsAndFacts...');
    const topic = 'Artificial Intelligence';
    const { terms, facts } = await openAiService.generateTermsAndFacts(topic);
    console.log(`✅ Generated ${terms.length} terms and ${facts.length} facts for "${topic}"`);
    console.log(`   Sample terms: ${terms.slice(0, 5).join(', ')}...`);
    console.log(`   Sample facts: ${facts.slice(0, 2).join(' | ')}...`);
    console.log('');

    // Test 2: Rewrite definition
    console.log('2. Testing rewriteDefinition...');
    const term = 'Machine Learning';
    const longDefinition = 'Machine learning is a subset of artificial intelligence that involves the development of algorithms and statistical models that enable computers to improve their performance on a specific task through experience, without being explicitly programmed for that task.';
    const rewritten = await openAiService.rewriteDefinition(term, longDefinition);
    console.log(`✅ Rewritten definition for "${term}":`);
    console.log(`   Short: ${rewritten.shortDef}`);
    console.log(`   Example: ${rewritten.example}`);
    console.log('');

    // Test 3: Generate fallback definition
    console.log('3. Testing generateFallbackDefinition...');
    const unknownTerm = 'Quantum Neural Network';
    const fallback = await openAiService.generateFallbackDefinition(unknownTerm);
    console.log(`✅ Fallback definition for "${unknownTerm}":`);
    console.log(`   Definition: ${fallback.definition}`);
    console.log(`   Explanation: ${fallback.explanation}`);
    console.log('');

    console.log('🎉 All enhanced prompts working successfully!');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
}

// Run the test
testEnhancedPrompts();
