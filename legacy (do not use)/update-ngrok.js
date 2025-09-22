#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

/**
 * Script to update ngrok URLs across the entire Larry project
 * Usage: node update-ngrok.js <new-ngrok-url>
 * Example: node update-ngrok.js https://abc123.ngrok-free.app
 */

const NEW_NGROK_URL = process.argv[2];

if (!NEW_NGROK_URL) {
  console.error('❌ Please provide a new ngrok URL');
  console.error('Usage: node update-ngrok.js <new-ngrok-url>');
  console.error('Example: node update-ngrok.js https://abc123.ngrok-free.app');
  process.exit(1);
}

// Validate URL format
try {
  new URL(NEW_NGROK_URL);
} catch (error) {
  console.error('❌ Invalid URL format:', NEW_NGROK_URL);
  process.exit(1);
}

console.log(`🔄 Updating ngrok URL to: ${NEW_NGROK_URL}`);

// Files that need to be updated
const FILES_TO_UPDATE = [
  // Frontend config files
  'app/app.config.ts',
  'app/app.json',
  
  // Backend config files
  'api/src/config.ts',
  'api/.env',
  
  // Docker config
  'docker-compose.yaml',
];

// Patterns to find and replace
const NGROK_PATTERNS = [
  // Match any ngrok URL
  /https:\/\/[a-f0-9]{12}\.ngrok-free\.app/g,
  /https:\/\/[a-f0-9]{10,16}\.ngrok-free\.app/g,
];

let filesUpdated = 0;
let totalReplacements = 0;

FILES_TO_UPDATE.forEach(filePath => {
  const fullPath = path.join(__dirname, filePath);
  
  if (!fs.existsSync(fullPath)) {
    console.log(`⚠️  File not found: ${filePath}`);
    return;
  }
  
  try {
    let content = fs.readFileSync(fullPath, 'utf8');
    let fileReplacements = 0;
    
    // Apply all patterns
    NGROK_PATTERNS.forEach(pattern => {
      const matches = content.match(pattern);
      if (matches) {
        fileReplacements += matches.length;
        content = content.replace(pattern, NEW_NGROK_URL);
      }
    });
    
    if (fileReplacements > 0) {
      fs.writeFileSync(fullPath, content, 'utf8');
      console.log(`✅ Updated ${filePath} (${fileReplacements} replacements)`);
      filesUpdated++;
      totalReplacements += fileReplacements;
    } else {
      console.log(`ℹ️  No ngrok URLs found in ${filePath}`);
    }
  } catch (error) {
    console.error(`❌ Error updating ${filePath}:`, error.message);
  }
});

console.log(`\n🎉 Update complete!`);
console.log(`📁 Files updated: ${filesUpdated}`);
console.log(`🔄 Total replacements: ${totalReplacements}`);

if (totalReplacements > 0) {
  console.log(`\n📋 Next steps:`);
  console.log(`1. Restart Docker containers: docker-compose down && docker-compose up -d`);
  console.log(`2. Rebuild and restart iOS app: cd app && npx expo run:ios`);
  console.log(`3. Test authentication flow`);
}
