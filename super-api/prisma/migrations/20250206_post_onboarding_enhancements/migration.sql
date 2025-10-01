-- CreateEnum
CREATE TYPE "public"."TermRelevance" AS ENUM ('RELATED', 'UNRELATED');

-- AlterTable
ALTER TABLE "public"."Topic" ADD COLUMN     "maxTerms" INTEGER NOT NULL DEFAULT 10;

-- AlterTable
ALTER TABLE "public"."UserTopic" ADD COLUMN     "enabled" BOOLEAN NOT NULL DEFAULT true;

-- AlterTable
ALTER TABLE "public"."Wordbank" ADD COLUMN     "relevance" "public"."TermRelevance" NOT NULL DEFAULT 'RELATED';

-- CreateTable
CREATE TABLE "public"."GenerationLog" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "topicId" TEXT,
    "termId" TEXT,
    "promptType" TEXT NOT NULL,
    "model" TEXT NOT NULL,
    "costEstimate" DOUBLE PRECISION,
    "success" BOOLEAN NOT NULL DEFAULT true,
    "errorMessage" TEXT,
    "metadata" JSONB NOT NULL DEFAULT '{}',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "GenerationLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "GenerationLog_userId_idx" ON "public"."GenerationLog"("userId");

-- CreateIndex
CREATE INDEX "GenerationLog_topicId_idx" ON "public"."GenerationLog"("topicId");

-- CreateIndex
CREATE INDEX "GenerationLog_promptType_idx" ON "public"."GenerationLog"("promptType");

-- CreateIndex
CREATE INDEX "GenerationLog_createdAt_idx" ON "public"."GenerationLog"("createdAt");

-- AddForeignKey
ALTER TABLE "public"."GenerationLog" ADD CONSTRAINT "GenerationLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."GenerationLog" ADD CONSTRAINT "GenerationLog_topicId_fkey" FOREIGN KEY ("topicId") REFERENCES "public"."Topic"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."GenerationLog" ADD CONSTRAINT "GenerationLog_termId_fkey" FOREIGN KEY ("termId") REFERENCES "public"."Term"("id") ON DELETE SET NULL ON UPDATE CASCADE;

