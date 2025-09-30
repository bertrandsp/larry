-- Migration: Enhance Topic model for global custom topics
-- Run this in Supabase SQL Editor

-- Add new columns to Topic table
ALTER TABLE "Topic" 
ADD COLUMN IF NOT EXISTS "description" TEXT,
ADD COLUMN IF NOT EXISTS "isCustom" BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS "createdByUserId" TEXT,
ADD COLUMN IF NOT EXISTS "usageCount" INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS "isActive" BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS "updatedAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP;

-- Make name unique (this might fail if there are duplicates, handle manually)
-- ALTER TABLE "Topic" ADD CONSTRAINT "Topic_name_key" UNIQUE ("name");

-- Update existing topics to be non-custom
UPDATE "Topic" SET 
    "isCustom" = false,
    "usageCount" = 1,
    "isActive" = true
WHERE "isCustom" IS NULL;

-- Add comments for documentation
COMMENT ON COLUMN "Topic"."description" IS 'Optional description for the topic';
COMMENT ON COLUMN "Topic"."isCustom" IS 'Whether this is a user-created custom topic';
COMMENT ON COLUMN "Topic"."createdByUserId" IS 'ID of user who created this topic (for metadata only, not a foreign key)';
COMMENT ON COLUMN "Topic"."usageCount" IS 'How many users have selected this topic';
COMMENT ON COLUMN "Topic"."isActive" IS 'Whether this topic is still available for selection';

-- Create index for better performance on custom topics
CREATE INDEX IF NOT EXISTS "Topic_isCustom_idx" ON "Topic"("isCustom");
CREATE INDEX IF NOT EXISTS "Topic_isActive_idx" ON "Topic"("isActive");
CREATE INDEX IF NOT EXISTS "Topic_usageCount_idx" ON "Topic"("usageCount");
