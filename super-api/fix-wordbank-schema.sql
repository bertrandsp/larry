-- Fix Wordbank Schema: Add missing timestamp columns
-- Run this in your Supabase SQL Editor

BEGIN;

-- Add missing timestamp columns to Wordbank table
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

COMMIT;
