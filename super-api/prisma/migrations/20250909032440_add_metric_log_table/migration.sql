-- CreateTable
CREATE TABLE "MetricLog" (
    "id" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "topicId" TEXT,
    "termId" TEXT,
    "factId" TEXT,
    "message" TEXT NOT NULL,
    "metadata" JSONB NOT NULL DEFAULT '{}',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "MetricLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "MetricLog_type_idx" ON "MetricLog"("type");

-- CreateIndex
CREATE INDEX "MetricLog_topicId_idx" ON "MetricLog"("topicId");

-- CreateIndex
CREATE INDEX "MetricLog_createdAt_idx" ON "MetricLog"("createdAt");

-- CreateIndex
CREATE INDEX "MetricLog_type_createdAt_idx" ON "MetricLog"("type", "createdAt");

-- AddForeignKey
ALTER TABLE "MetricLog" ADD CONSTRAINT "MetricLog_topicId_fkey" FOREIGN KEY ("topicId") REFERENCES "Topic"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MetricLog" ADD CONSTRAINT "MetricLog_termId_fkey" FOREIGN KEY ("termId") REFERENCES "Term"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MetricLog" ADD CONSTRAINT "MetricLog_factId_fkey" FOREIGN KEY ("factId") REFERENCES "Fact"("id") ON DELETE SET NULL ON UPDATE CASCADE;
