/*
  Warnings:

  - Added the required column `updatedAt` to the `Fact` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updatedAt` to the `Term` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Fact" ADD COLUMN     "moderationNote" TEXT,
ADD COLUMN     "moderationStatus" TEXT NOT NULL DEFAULT 'pending',
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "updatedByAdmin" BOOLEAN NOT NULL DEFAULT false;

-- AlterTable
ALTER TABLE "Term" ADD COLUMN     "moderationNote" TEXT,
ADD COLUMN     "moderationStatus" TEXT NOT NULL DEFAULT 'pending',
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "updatedByAdmin" BOOLEAN NOT NULL DEFAULT false;
