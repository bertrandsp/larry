// Test imports to see what's failing
console.log('Testing imports...');

try {
  console.log('1. Testing promptBuilder...');
  require('./src/promptBuilder.ts');
  console.log('✅ promptBuilder imported successfully');
} catch (error) {
  console.error('❌ promptBuilder import failed:', error.message);
}

try {
  console.log('2. Testing openAiService...');
  require('./src/services/openAiService.ts');
  console.log('✅ openAiService imported successfully');
} catch (error) {
  console.error('❌ openAiService import failed:', error.message);
}

try {
  console.log('3. Testing externalSources...');
  require('./src/services/externalSources.ts');
  console.log('✅ externalSources imported successfully');
} catch (error) {
  console.error('❌ externalSources import failed:', error.message);
}

try {
  console.log('4. Testing validationService...');
  require('./src/services/validationService.ts');
  console.log('✅ validationService imported successfully');
} catch (error) {
  console.error('❌ validationService import failed:', error.message);
}

try {
  console.log('5. Testing dualPipelineTermService...');
  require('./src/services/dualPipelineTermService.ts');
  console.log('✅ dualPipelineTermService imported successfully');
} catch (error) {
  console.error('❌ dualPipelineTermService import failed:', error.message);
}

try {
  console.log('6. Testing generate API...');
  require('./src/api/generate.ts');
  console.log('✅ generate API imported successfully');
} catch (error) {
  console.error('❌ generate API import failed:', error.message);
}

console.log('Import testing complete.');



