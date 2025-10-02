-- Fix Schema Issues in Supabase
-- Run this in your Supabase SQL Editor to resolve the current errors

BEGIN;

-- 1. Add missing 'updatedAt' column to GenerationLog table
ALTER TABLE "GenerationLog" 
ADD COLUMN IF NOT EXISTS "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- 2. Add missing 'createdAt' and 'updatedAt' columns to Wordbank table
ALTER TABLE "Wordbank" 
ADD COLUMN IF NOT EXISTS "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- 3. Update existing records to have timestamp values
UPDATE "GenerationLog" SET 
    "updatedAt" = NOW()
WHERE "updatedAt" IS NULL;

UPDATE "Wordbank" SET 
    "createdAt" = NOW(),
    "updatedAt" = NOW()
WHERE "createdAt" IS NULL OR "updatedAt" IS NULL;

-- 4. Add indexes for better performance
CREATE INDEX IF NOT EXISTS "GenerationLog_updatedAt_idx" ON "GenerationLog"("updatedAt");
CREATE INDEX IF NOT EXISTS "Wordbank_createdAt_idx" ON "Wordbank"("createdAt");
CREATE INDEX IF NOT EXISTS "Wordbank_updatedAt_idx" ON "Wordbank"("updatedAt");

COMMIT;
