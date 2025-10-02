-- Add password field to User table
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard/project/greuppfemzgunszxpveq/sql

-- Add password column to User table
ALTER TABLE "public"."User" 
ADD COLUMN IF NOT EXISTS "password" TEXT;

-- Add comment to document the field
COMMENT ON COLUMN "public"."User"."password" IS 'Hashed password for email/password authentication';

-- Verify the column was added
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'User' AND table_schema = 'public' 
ORDER BY ordinal_position;
