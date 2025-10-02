-- Fix Topic Management Schema Issues
-- Run this in your Supabase SQL Editor to add missing columns

BEGIN;

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
    WHEN LOWER("name") LIKE '%art%' OR LOWER("name") LIKE '%music%' OR LOWER("name") LIKE '%creative%' THEN 'arts'
    WHEN LOWER("name") LIKE '%science%' OR LOWER("name") LIKE '%research%' THEN 'science'
    WHEN LOWER("name") LIKE '%sport%' OR LOWER("name") LIKE '%fitness%' THEN 'sports'
    WHEN LOWER("name") LIKE '%education%' OR LOWER("name") LIKE '%academic%' THEN 'academic'
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

COMMIT;

-- Verify the changes
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
