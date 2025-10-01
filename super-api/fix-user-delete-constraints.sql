-- Fix user delete constraints for safe cascading deletes
-- This migration adds proper ON DELETE behavior to foreign key constraints

BEGIN;

-- 1. UserTopic: Delete user-topic relationships when user is deleted
-- This is safe because UserTopic is purely a junction table for user preferences
ALTER TABLE "UserTopic" 
DROP CONSTRAINT IF EXISTS "UserTopic_userId_fkey",
ADD CONSTRAINT "UserTopic_userId_fkey" 
FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE;

-- 2. Delivery: Already has CASCADE, but let's ensure it's correct
ALTER TABLE "Delivery" 
DROP CONSTRAINT IF EXISTS "Delivery_userId_fkey",
ADD CONSTRAINT "Delivery_userId_fkey" 
FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE;

-- 3. Wordbank: Delete user's wordbank entries when user is deleted
ALTER TABLE "Wordbank" 
DROP CONSTRAINT IF EXISTS "Wordbank_userId_fkey",
ADD CONSTRAINT "Wordbank_userId_fkey" 
FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE;

-- 4. GenerationLog: Delete user's generation logs when user is deleted
ALTER TABLE "GenerationLog" 
DROP CONSTRAINT IF EXISTS "GenerationLog_userId_fkey",
ADD CONSTRAINT "GenerationLog_userId_fkey" 
FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE;

-- 5. UserQuota: Delete user's quota when user is deleted
ALTER TABLE "UserQuota" 
DROP CONSTRAINT IF EXISTS "UserQuota_userId_fkey",
ADD CONSTRAINT "UserQuota_userId_fkey" 
FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE;

-- 6. For custom topics created by the user:
-- We'll use SET NULL for createdByUserId so the topic remains but loses the creator reference
-- This preserves content for other users while cleaning up the user reference
ALTER TABLE "Topic" 
DROP CONSTRAINT IF EXISTS "Topic_createdByUserId_fkey",
ADD CONSTRAINT "Topic_createdByUserId_fkey" 
FOREIGN KEY ("createdByUserId") REFERENCES "User"("id") ON DELETE SET NULL;

-- Add legal compliance fields to AnonymizedLearningData table
ALTER TABLE "AnonymizedLearningData" 
ADD COLUMN IF NOT EXISTS "data_retention_reason" TEXT DEFAULT 'Educational research and product improvement',
ADD COLUMN IF NOT EXISTS "gdpr_compliant" BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS "anonymization_method" TEXT DEFAULT 'Statistical aggregation and demographic bucketing',
ADD COLUMN IF NOT EXISTS "data_processing_basis" TEXT DEFAULT 'Legitimate interest for educational research',
ADD COLUMN IF NOT EXISTS "retention_period" TEXT DEFAULT 'Indefinite for research purposes',
ADD COLUMN IF NOT EXISTS "user_consent_obtained" BOOLEAN DEFAULT true;

COMMIT;
