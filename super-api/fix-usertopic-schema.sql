-- Fix UserTopic schema issues in Supabase
-- Run this in your Supabase SQL Editor to resolve the current errors

BEGIN;

-- Add missing 'createdAt' and 'updatedAt' columns to UserTopic table
ALTER TABLE "UserTopic" 
ADD COLUMN IF NOT EXISTS "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Update existing records to have timestamp values
UPDATE "UserTopic" SET 
    "createdAt" = NOW(),
    "updatedAt" = NOW()
WHERE "createdAt" IS NULL OR "updatedAt" IS NULL;

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS "UserTopic_createdAt_idx" ON "UserTopic"("createdAt");
CREATE INDEX IF NOT EXISTS "UserTopic_updatedAt_idx" ON "UserTopic"("updatedAt");

COMMIT;
