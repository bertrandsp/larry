-- Clean up and setup proper topics for Larry onboarding
-- Run this script in Supabase SQL Editor

-- Step 1: Clean up bad/placeholder topics
DELETE FROM "UserTopic" WHERE "topicId" IN (
    SELECT id FROM "Topic" WHERE name LIKE 'custom-%'
);
DELETE FROM "UserTopic" WHERE "topicId" IN (
    SELECT id FROM "Topic" WHERE name LIKE 'preview-topic-%'
);

DELETE FROM "Topic" WHERE name LIKE 'custom-%';
DELETE FROM "Topic" WHERE name LIKE 'preview-topic-%';

-- Step 2: Add proper predefined topics
INSERT INTO "Topic" (id, name) VALUES 
    ('topic-technology-programming', 'Technology & Programming'),
    ('topic-business-finance', 'Business & Finance'),
    ('topic-health-wellness', 'Health & Wellness'),
    ('topic-science-research', 'Science & Research'),
    ('topic-arts-culture', 'Arts & Culture'),
    ('topic-travel-tourism', 'Travel & Tourism'),
    ('topic-sports-fitness', 'Sports & Fitness'),
    ('topic-education-learning', 'Education & Learning'),
    ('topic-food-cooking', 'Food & Cooking'),
    ('topic-photography-media', 'Photography & Media'),
    ('topic-music-entertainment', 'Music & Entertainment'),
    ('topic-environment-nature', 'Environment & Nature'),
    ('topic-career-professional', 'Career & Professional'),
    ('topic-language-literature', 'Language & Literature'),
    ('topic-history-heritage', 'History & Heritage'),
    ('topic-psychology-behavior', 'Psychology & Behavior'),
    ('topic-mathematics-statistics', 'Mathematics & Statistics'),
    ('topic-philosophy-ethics', 'Philosophy & Ethics'),
    ('topic-economics-policy', 'Economics & Policy'),
    ('topic-law-justice', 'Law & Justice');

-- Step 3: Verify the cleanup
SELECT 
    id, 
    name,
    CASE 
        WHEN name LIKE 'custom-%' THEN 'BAD - Custom UUID'
        WHEN name LIKE 'preview-topic-%' THEN 'BAD - Preview'
        WHEN name ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN 'BAD - Raw UUID'
        ELSE 'GOOD'
    END as status
FROM "Topic" 
ORDER BY 
    CASE 
        WHEN name LIKE 'custom-%' THEN 1
        WHEN name LIKE 'preview-topic-%' THEN 1
        WHEN name ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN 1
        ELSE 2
    END,
    name;
