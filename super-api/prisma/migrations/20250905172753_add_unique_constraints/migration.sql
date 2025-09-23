/*
  Warnings:

  - A unique constraint covering the columns `[topicId,fact]` on the table `Fact` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[topicId,term]` on the table `Term` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "Fact_topicId_fact_key" ON "Fact"("topicId", "fact");

-- CreateIndex
CREATE UNIQUE INDEX "Term_topicId_term_key" ON "Term"("topicId", "term");
