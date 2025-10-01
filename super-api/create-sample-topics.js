#!/usr/bin/env node

/**
 * Create Sample Topics Script
 * 
 * This script creates sample topics in the Supabase database
 * to enable topic analytics and user topic selection.
 */

const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY,
  {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
      detectSessionInUrl: false,
    },
  }
);

const sampleTopics = [
  {
    id: 'topic-blockchain',
    name: 'Blockchain & Crypto',
    description: 'Cryptocurrency, DeFi, NFTs, and blockchain technology',
    category: 'Technology',
    difficulty: 'intermediate',
    maxTerms: 15,
    isGlobal: true,
    createdByUserId: null
  },
  {
    id: 'topic-ai',
    name: 'Artificial Intelligence',
    description: 'Machine learning, neural networks, and AI applications',
    category: 'Technology', 
    difficulty: 'advanced',
    maxTerms: 20,
    isGlobal: true,
    createdByUserId: null
  },
  {
    id: 'topic-startups',
    name: 'Startups & Entrepreneurship',
    description: 'Venture capital, business models, and startup culture',
    category: 'Business',
    difficulty: 'intermediate',
    maxTerms: 12,
    isGlobal: true,
    createdByUserId: null
  },
  {
    id: 'topic-finance',
    name: 'Finance & Investment',
    description: 'Trading, portfolio management, and financial markets',
    category: 'Business',
    difficulty: 'intermediate',
    maxTerms: 18,
    isGlobal: true,
    createdByUserId: null
  },
  {
    id: 'topic-healthcare',
    name: 'Healthcare & Medicine',
    description: 'Medical terminology, healthcare systems, and biotechnology',
    category: 'Science',
    difficulty: 'advanced',
    maxTerms: 25,
    isGlobal: true,
    createdByUserId: null
  },
  {
    id: 'topic-sustainability',
    name: 'Sustainability & Climate',
    description: 'Environmental science, renewable energy, and climate action',
    category: 'Science',
    difficulty: 'intermediate',
    maxTerms: 16,
    isGlobal: true,
    createdByUserId: null
  }
];

async function createTopics() {
  console.log('🚀 Creating sample topics in Supabase...\n');
  
  for (const topic of sampleTopics) {
    try {
      console.log(`📝 Creating topic: ${topic.name} (${topic.id})`);
      
      const { data, error } = await supabase
        .from('Topic')
        .upsert({
          id: topic.id,
          name: topic.name,
          description: topic.description,
          maxTerms: topic.maxTerms,
          isCustom: false,
          isActive: true,
          usageCount: 0,
          createdByUserId: topic.createdByUserId
        }, {
          onConflict: 'id'
        });
      
      if (error) {
        console.error(`❌ Error creating topic ${topic.name}:`, error.message);
      } else {
        console.log(`✅ Created topic: ${topic.name}`);
      }
      
    } catch (error) {
      console.error(`❌ Failed to create topic ${topic.name}:`, error.message);
    }
  }
  
  console.log('\n📊 Verifying topics were created...');
  
  try {
    const { data: topics, error } = await supabase
      .from('Topic')
      .select('id, name, description, maxTerms, usageCount')
      .eq('isCustom', false)
      .eq('isActive', true)
      .order('name');
    
    if (error) {
      console.error('❌ Error fetching topics:', error.message);
    } else {
      console.log(`\n✅ Found ${topics.length} global topics:`);
      topics.forEach(topic => {
        console.log(`   • ${topic.name} (${topic.id}) - Max ${topic.maxTerms} terms - ${topic.usageCount} users`);
      });
    }
    
  } catch (error) {
    console.error('❌ Error verifying topics:', error.message);
  }
}

async function main() {
  console.log('🎯 Sample Topics Creation Script\n');
  
  await createTopics();
  
  console.log('\n🎉 Topic creation completed!');
  console.log('💡 Users can now select these topics during onboarding');
  console.log('📈 Analytics will now show topic popularity and preferences');
}

main().catch(console.error);
