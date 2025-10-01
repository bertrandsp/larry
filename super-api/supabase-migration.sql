-- Add missing columns to Supabase database schema
-- Run this in your Supabase SQL Editor

-- Add maxTerms column to Topic table
ALTER TABLE "Topic" 
ADD COLUMN IF NOT EXISTS "maxTerms" INTEGER DEFAULT 10;

-- Add enabled column to UserTopic table  
ALTER TABLE "UserTopic"
ADD COLUMN IF NOT EXISTS "enabled" BOOLEAN DEFAULT true;

-- Add relevance column to Wordbank table
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'TermRelevance') THEN
        CREATE TYPE "TermRelevance" AS ENUM ('RELATED', 'UNRELATED');
    END IF;
END $$;

ALTER TABLE "Wordbank"
ADD COLUMN IF NOT EXISTS "relevance" "TermRelevance" DEFAULT 'RELATED';

-- Create GenerationLog table if it doesn't exist
CREATE TABLE IF NOT EXISTS "GenerationLog" (
    "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
    "userId" TEXT NOT NULL,
    "topicId" TEXT,
    "termId" TEXT,
    "promptType" TEXT NOT NULL,
    "model" TEXT NOT NULL,
    "costEstimate" REAL,
    "success" BOOLEAN DEFAULT true,
    "errorMessage" TEXT,
    "metadata" JSONB DEFAULT '{}',
    "createdAt" TIMESTAMPTZ DEFAULT NOW(),
    
    -- Foreign key constraints
    CONSTRAINT "GenerationLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id"),
    CONSTRAINT "GenerationLog_topicId_fkey" FOREIGN KEY ("topicId") REFERENCES "Topic"("id"),
    CONSTRAINT "GenerationLog_termId_fkey" FOREIGN KEY ("termId") REFERENCES "Term"("id")
);

-- Create indexes for GenerationLog
CREATE INDEX IF NOT EXISTS "GenerationLog_userId_idx" ON "GenerationLog"("userId");
CREATE INDEX IF NOT EXISTS "GenerationLog_topicId_idx" ON "GenerationLog"("topicId");
CREATE INDEX IF NOT EXISTS "GenerationLog_promptType_idx" ON "GenerationLog"("promptType");
CREATE INDEX IF NOT EXISTS "GenerationLog_createdAt_idx" ON "GenerationLog"("createdAt");

-- Update existing records to have default values
UPDATE "Topic" SET "maxTerms" = 10 WHERE "maxTerms" IS NULL;
UPDATE "UserTopic" SET "enabled" = true WHERE "enabled" IS NULL;
UPDATE "Wordbank" SET "relevance" = 'RELATED' WHERE "relevance" IS NULL;

COMMIT;
