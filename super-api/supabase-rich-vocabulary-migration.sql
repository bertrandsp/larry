-- Enhanced Vocabulary Migration: Add Rich Vocabulary Fields
-- Run this in your Supabase SQL Editor to add synonyms, antonyms, and related terms

BEGIN;

-- Add rich vocabulary fields to Term table
ALTER TABLE "Term" 
ADD COLUMN IF NOT EXISTS "synonyms" JSONB DEFAULT '[]',
ADD COLUMN IF NOT EXISTS "antonyms" JSONB DEFAULT '[]', 
ADD COLUMN IF NOT EXISTS "relatedTerms" JSONB DEFAULT '[]',
ADD COLUMN IF NOT EXISTS "etymology" TEXT,
ADD COLUMN IF NOT EXISTS "pronunciation" TEXT,
ADD COLUMN IF NOT EXISTS "partOfSpeech" TEXT,
ADD COLUMN IF NOT EXISTS "difficulty" INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS "tags" JSONB DEFAULT '[]';

-- Update existing records to have default values for new fields
UPDATE "Term" SET 
    "synonyms" = '[]',
    "antonyms" = '[]',
    "relatedTerms" = '[]',
    "tags" = '[]',
    "difficulty" = 1
WHERE "synonyms" IS NULL OR "antonyms" IS NULL OR "relatedTerms" IS NULL OR "tags" IS NULL OR "difficulty" IS NULL;

-- Create indexes for better performance on JSON fields
CREATE INDEX IF NOT EXISTS "Term_synonyms_idx" ON "Term" USING GIN ("synonyms");
CREATE INDEX IF NOT EXISTS "Term_antonyms_idx" ON "Term" USING GIN ("antonyms");
CREATE INDEX IF NOT EXISTS "Term_relatedTerms_idx" ON "Term" USING GIN ("relatedTerms");
CREATE INDEX IF NOT EXISTS "Term_tags_idx" ON "Term" USING GIN ("tags");
CREATE INDEX IF NOT EXISTS "Term_difficulty_idx" ON "Term"("difficulty");
CREATE INDEX IF NOT EXISTS "Term_partOfSpeech_idx" ON "Term"("partOfSpeech");

COMMIT;
