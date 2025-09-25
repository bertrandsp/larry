-- Larry AI Vocabulary App - Supabase Schema
-- This replaces the Prisma schema with native PostgreSQL tables

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  subscription TEXT DEFAULT 'free',
  open_ai_first_preferred BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Canonical Sets table (referenced by topics and terms)
CREATE TABLE IF NOT EXISTS canonical_sets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4()
);

-- Topics table
CREATE TABLE IF NOT EXISTS topics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  canonical_set_id UUID REFERENCES canonical_sets(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User Topics (many-to-many relationship)
CREATE TABLE IF NOT EXISTS user_topics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  topic_id UUID REFERENCES topics(id) ON DELETE CASCADE,
  weight INTEGER NOT NULL,
  UNIQUE(user_id, topic_id)
);

-- Terms table
CREATE TABLE IF NOT EXISTS terms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  topic_id UUID REFERENCES topics(id) ON DELETE CASCADE,
  canonical_set_id UUID REFERENCES canonical_sets(id),
  term TEXT NOT NULL,
  definition TEXT NOT NULL,
  example TEXT NOT NULL,
  source TEXT NOT NULL,
  source_url TEXT,
  verified BOOLEAN DEFAULT false,
  gpt_generated BOOLEAN DEFAULT false,
  confidence_score DECIMAL(3,2) DEFAULT 0.0,
  category TEXT,
  complexity_level TEXT,
  moderation_status TEXT DEFAULT 'pending',
  moderation_note TEXT,
  updated_by_admin BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(topic_id, term)
);

-- Facts table
CREATE TABLE IF NOT EXISTS facts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  topic_id UUID REFERENCES topics(id) ON DELETE CASCADE,
  fact TEXT NOT NULL,
  source TEXT NOT NULL,
  source_url TEXT,
  gpt_generated BOOLEAN DEFAULT false,
  category TEXT,
  moderation_status TEXT DEFAULT 'pending',
  moderation_note TEXT,
  updated_by_admin BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(topic_id, fact)
);

-- User Quota table
CREATE TABLE IF NOT EXISTS user_quotas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  current_usage INTEGER DEFAULT 0,
  period_start TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_reset TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Metric Logs table
CREATE TABLE IF NOT EXISTS metric_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  type TEXT NOT NULL,
  topic_id UUID REFERENCES topics(id),
  term_id UUID REFERENCES terms(id),
  fact_id UUID REFERENCES facts(id),
  message TEXT NOT NULL,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_topics_user_id ON user_topics(user_id);
CREATE INDEX IF NOT EXISTS idx_user_topics_topic_id ON user_topics(topic_id);
CREATE INDEX IF NOT EXISTS idx_terms_topic_id ON terms(topic_id);
CREATE INDEX IF NOT EXISTS idx_facts_topic_id ON facts(topic_id);
CREATE INDEX IF NOT EXISTS idx_user_quotas_user_id ON user_quotas(user_id);
CREATE INDEX IF NOT EXISTS idx_metric_logs_type ON metric_logs(type);
CREATE INDEX IF NOT EXISTS idx_metric_logs_topic_id ON metric_logs(topic_id);
CREATE INDEX IF NOT EXISTS idx_metric_logs_created_at ON metric_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_metric_logs_type_created_at ON metric_logs(type, created_at);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_terms_updated_at BEFORE UPDATE ON terms
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_facts_updated_at BEFORE UPDATE ON facts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_quotas_updated_at BEFORE UPDATE ON user_quotas
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (RLS) - optional, can be configured later
-- ALTER TABLE users ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE topics ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE terms ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE facts ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE user_quotas ENABLE ROW LEVEL SECURITY;
