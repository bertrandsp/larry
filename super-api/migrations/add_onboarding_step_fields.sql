-- Migration: Add new onboarding step fields to User table
-- Run this in Supabase SQL Editor

-- Add new columns for onboarding step tracking
ALTER TABLE "User" 
ADD COLUMN IF NOT EXISTS "onboardingSource" TEXT,
ADD COLUMN IF NOT EXISTS "learningLevel" TEXT,
ADD COLUMN IF NOT EXISTS "widgetOptIn" BOOLEAN,
ADD COLUMN IF NOT EXISTS "onboardingStep" TEXT DEFAULT 'welcome';

-- Add comments for documentation
COMMENT ON COLUMN "User"."onboardingSource" IS 'How the user found the app (appStore, friend, social, etc.)';
COMMENT ON COLUMN "User"."learningLevel" IS 'User skill level (scratch, beginner, intermediate, advanced, professional)';
COMMENT ON COLUMN "User"."widgetOptIn" IS 'Whether user opted in for widget';
COMMENT ON COLUMN "User"."onboardingStep" IS 'Current onboarding step for tracking progress';

-- Update existing users to have default onboarding step
UPDATE "User" SET "onboardingStep" = 'welcome' WHERE "onboardingStep" IS NULL;
