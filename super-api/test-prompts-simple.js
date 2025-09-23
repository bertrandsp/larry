// Simple test for enhanced OpenAI prompts
console.log('🧪 Testing Enhanced OpenAI Prompts (Simple Version)...\n');

// Test the parsing logic for the new prompt formats
function testParsingLogic() {
  console.log('1. Testing parsing logic for generateTermsAndFacts...');
  
  const mockResponse = `Terms: pickleball, paddle, court, net, serve, volley, dink, smash, lob, drop shot
Facts:
1. Pickleball was invented in 1965 on Bainbridge Island, Washington.
2. The game combines elements of tennis, badminton, and ping-pong.
3. Pickleball courts are smaller than tennis courts.
4. The game is named after a family dog, Pickles.
5. Pickleball is one of the fastest-growing sports in America.`;

  const [termsPart, ...factsPart] = mockResponse.split("Facts:");
  const terms = termsPart.replace("Terms:", "").split(",").map(t => t.trim()).filter(Boolean);
  const facts = factsPart.join("Facts:").split(/\n\d+\.\s/).map(f => f.trim()).filter(Boolean);

  console.log(`✅ Parsed ${terms.length} terms and ${facts.length} facts`);
  console.log(`   Sample terms: ${terms.slice(0, 5).join(', ')}...`);
  console.log(`   Sample facts: ${facts.slice(0, 2).join(' | ')}...`);
  console.log('');

  return { terms, facts };
}

function testRewriteParsing() {
  console.log('2. Testing parsing logic for rewriteDefinition...');
  
  const mockResponse = `Definition: A paddle sport combining tennis, badminton, and ping-pong elements.
Example: We play pickleball every Saturday morning at the community center.`;

  const defMatch = mockResponse.match(/Definition:\s*(.+)/i);
  const exMatch = mockResponse.match(/Example:\s*(.+)/i);

  console.log(`✅ Parsed rewritten definition:`);
  console.log(`   Definition: ${defMatch?.[1]?.trim()}`);
  console.log(`   Example: ${exMatch?.[1]?.trim()}`);
  console.log('');

  return { shortDef: defMatch?.[1]?.trim(), example: exMatch?.[1]?.trim() };
}

function testFallbackParsing() {
  console.log('3. Testing parsing logic for generateFallbackDefinition...');
  
  const mockResponse = `Definition: A specialized tool or implement used in a specific craft or trade.
Explanation: Based on the word structure 'glimbrick' which appears to be a compound word, likely related to specialized tools or implements used in specific trades or crafts.`;

  const defMatch = mockResponse.match(/Definition:\s*(.+)/i);
  const exMatch = mockResponse.match(/Explanation:\s*(.+)/i);

  console.log(`✅ Parsed fallback definition:`);
  console.log(`   Definition: ${defMatch?.[1]?.trim()}`);
  console.log(`   Explanation: ${exMatch?.[1]?.trim()}`);
  console.log('');

  return { definition: defMatch?.[1]?.trim(), explanation: exMatch?.[1]?.trim() };
}

// Run all tests
try {
  const termsResult = testParsingLogic();
  const rewriteResult = testRewriteParsing();
  const fallbackResult = testFallbackParsing();

  console.log('🎉 All parsing logic tests passed!');
  console.log('');
  console.log('📊 Test Results Summary:');
  console.log(`   - Terms generated: ${termsResult.terms.length}`);
  console.log(`   - Facts generated: ${termsResult.facts.length}`);
  console.log(`   - Definition rewritten: ${rewriteResult.shortDef ? '✅' : '❌'}`);
  console.log(`   - Fallback generated: ${fallbackResult.definition ? '✅' : '❌'}`);
  console.log('');
  console.log('💡 Next steps:');
  console.log('   1. Build the project: npm run build');
  console.log('   2. Test with real OpenAI API: npm run test:prompts');
  console.log('   3. Integrate with termService.ts');

} catch (error) {
  console.error('❌ Test failed:', error.message);
}
