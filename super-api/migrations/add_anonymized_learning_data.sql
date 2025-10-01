-- Add AnonymizedLearningData table
CREATE TABLE "public"."AnonymizedLearningData" (
    "id" TEXT NOT NULL,
    "userAgeBracket" TEXT,
    "learningLevel" TEXT,
    "professionCategory" TEXT,
    "preferredDifficulty" TEXT,
    "onboardingCompleted" BOOLEAN NOT NULL,
    "dailyWordGoal" INTEGER NOT NULL,
    "totalTermsLearned" INTEGER NOT NULL,
    "averageLearningSpeed" INTEGER,
    "streakAchieved" INTEGER NOT NULL,
    "topicPreferences" TEXT[] NOT NULL,
    "termsMastered" INTEGER NOT NULL,
    "termsStruggledWith" INTEGER NOT NULL,
    "mostEffectiveTopics" TEXT[] NOT NULL,
    "learningPattern" TEXT NOT NULL,
    "daysActive" INTEGER NOT NULL,
    "accountCreatedAt" TIMESTAMP(3) NOT NULL,
    "anonymizedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "cohortGroup" TEXT NOT NULL,
    "learningStyle" TEXT,
    "successMetrics" JSONB,

    CONSTRAINT "AnonymizedLearningData_pkey" PRIMARY KEY ("id")
);
