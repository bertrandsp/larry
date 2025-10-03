-- Complete Database Schema Update for Larry App
-- Run this in your Supabase SQL Editor to fix all schema issues
-- This combines all necessary schema fixes into one script

BEGIN;

-- =====================================================
-- 1. Fix Topic table - Add category column
-- =====================================================

-- Add missing category column to Topic table
ALTER TABLE "Topic" 
ADD COLUMN IF NOT EXISTS "category" TEXT DEFAULT 'other';

-- Update existing topics with default categories based on name patterns
UPDATE "Topic" SET "category" = 
  CASE 
    WHEN LOWER("name") LIKE '%tech%' OR LOWER("name") LIKE '%software%' OR LOWER("name") LIKE '%programming%' OR LOWER("name") LIKE '%computer%' THEN 'technology'
    WHEN LOWER("name") LIKE '%business%' OR LOWER("name") LIKE '%finance%' OR LOWER("name") LIKE '%marketing%' THEN 'finance'
    WHEN LOWER("name") LIKE '%travel%' OR LOWER("name") LIKE '%culture%' OR LOWER("name") LIKE '%language%' THEN 'travel'
    WHEN LOWER("name") LIKE '%health%' OR LOWER("name") LIKE '%medical%' OR LOWER("name") LIKE '%wellness%' THEN 'health'
    WHEN LOWER("name") LIKE '%art%' OR LOWER("name") LIKE '%music%' OR LOWER("name") LIKE '%creative%' OR LOWER("name") LIKE '%photography%' THEN 'arts'
    WHEN LOWER("name") LIKE '%science%' OR LOWER("name") LIKE '%research%' THEN 'science'
    WHEN LOWER("name") LIKE '%sport%' OR LOWER("name") LIKE '%fitness%' THEN 'sports'
    WHEN LOWER("name") LIKE '%education%' OR LOWER("name") LIKE '%academic%' THEN 'academic'
    WHEN LOWER("name") LIKE '%cooking%' OR LOWER("name") LIKE '%culinary%' THEN 'lifestyle'
    WHEN LOWER("name") LIKE '%sustainable%' OR LOWER("name") LIKE '%environment%' THEN 'lifestyle'
    ELSE 'other'
  END
WHERE "category" IS NULL OR "category" = 'other';

-- Create index for better performance on category filtering
CREATE INDEX IF NOT EXISTS "Topic_category_idx" ON "Topic"("category");

-- Ensure all topics have proper default values
UPDATE "Topic" SET 
  "isActive" = COALESCE("isActive", true),
  "usageCount" = COALESCE("usageCount", 0),
  "isCustom" = COALESCE("isCustom", false)
WHERE "isActive" IS NULL OR "usageCount" IS NULL OR "isCustom" IS NULL;

-- =====================================================
-- 2. Fix GenerationLog table - Add missing updatedAt
-- =====================================================

-- Add missing 'updatedAt' column to GenerationLog table
ALTER TABLE "GenerationLog" 
ADD COLUMN IF NOT EXISTS "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Update existing records to have timestamp values
UPDATE "GenerationLog" SET 
    "updatedAt" = NOW()
WHERE "updatedAt" IS NULL;

-- Add index for better performance
CREATE INDEX IF NOT EXISTS "GenerationLog_updatedAt_idx" ON "GenerationLog"("updatedAt");

-- =====================================================
-- 3. Fix Wordbank table - Add missing timestamps
-- =====================================================

-- Add missing 'createdAt' and 'updatedAt' columns to Wordbank table
ALTER TABLE "Wordbank" 
ADD COLUMN IF NOT EXISTS "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Update existing records to have timestamp values
UPDATE "Wordbank" SET 
    "createdAt" = NOW(),
    "updatedAt" = NOW()
WHERE "createdAt" IS NULL OR "updatedAt" IS NULL;

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS "Wordbank_createdAt_idx" ON "Wordbank"("createdAt");
CREATE INDEX IF NOT EXISTS "Wordbank_updatedAt_idx" ON "Wordbank"("updatedAt");

-- =====================================================
-- 4. UserTopic table - DECISION NEEDED
-- =====================================================

-- OPTION A: Add timestamps to UserTopic (if you want them in the future)
-- Uncomment the lines below if you want to add timestamps to UserTopic:

ALTER TABLE "UserTopic" 
ADD COLUMN IF NOT EXISTS "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT NOW();

UPDATE "UserTopic" SET 
    "createdAt" = NOW(),
    "updatedAt" = NOW()
WHERE "createdAt" IS NULL OR "updatedAt" IS NULL;

CREATE INDEX IF NOT EXISTS "UserTopic_createdAt_idx" ON "UserTopic"("createdAt");
CREATE INDEX IF NOT EXISTS "UserTopic_updatedAt_idx" ON "UserTopic"("updatedAt");


-- OPTION B: Keep UserTopic without timestamps (current approach)
-- No changes needed - iOS app has been updated to not expect these fields

COMMIT;

-- =====================================================
-- 5. Verification Queries
-- =====================================================

-- Verify Topic categories
SELECT 
  "id", 
  "name", 
  "category", 
  "isActive", 
  "usageCount",
  "createdAt"
FROM "Topic" 
ORDER BY "name" 
LIMIT 10;

-- Verify GenerationLog has updatedAt
SELECT 
  "id",
  "createdAt",
  "updatedAt"
FROM "GenerationLog" 
LIMIT 5;

-- Verify Wordbank has timestamps
SELECT 
  "id",
  "createdAt",
  "updatedAt"
FROM "Wordbank" 
LIMIT 5;

-- Verify UserTopic structure (should NOT have timestamps)
SELECT 
  "id",
  "userId",
  "topicId",
  "weight",
  "enabled"
FROM "UserTopic" 
LIMIT 5;
