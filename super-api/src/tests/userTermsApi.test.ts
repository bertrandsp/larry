import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import request from "supertest";
import express from "express";
import userTermsRouter from "../api/user-terms";
import { prisma } from "../utils/prisma";
import * as generationLogService from "../services/generationLogService";

vi.mock("../utils/prisma", () => {
  const prismaMock = {
    wordbank: {
      upsert: vi.fn(),
      updateMany: vi.fn(),
      findMany: vi.fn(),
    },
  };
  return { prisma: prismaMock };
});

vi.mock("../services/generationLogService", () => ({
  logGeneration: vi.fn(),
}));

const mockPrisma = prisma as unknown as {
  wordbank: {
    upsert: ReturnType<typeof vi.fn>;
    updateMany: ReturnType<typeof vi.fn>;
    findMany: ReturnType<typeof vi.fn>;
  };
};

const mockedLogService = generationLogService as unknown as {
  logGeneration: ReturnType<typeof vi.fn>;
};

describe("user-terms routes", () => {
  const app = express();
  app.use(express.json());
  app.use(userTermsRouter);

  beforeEach(() => {
    vi.restoreAllMocks();
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  it("should mark a term as related", async () => {
    mockPrisma.wordbank.upsert.mockResolvedValue({});

    const response = await request(app)
      .put("/user/user-1/terms/term-1/relevance")
      .send({ related: true });

    expect(response.status).toBe(200);
    expect(response.body.related).toBe(true);
    expect(mockPrisma.wordbank.upsert).toHaveBeenCalled();
    expect(mockedLogService.logGeneration).toHaveBeenCalled();
  });

  it("should mark a term as unrelated", async () => {
    mockPrisma.wordbank.updateMany.mockResolvedValue({ count: 1 });

    const response = await request(app)
      .put("/user/user-1/terms/term-1/relevance")
      .send({ related: false });

    expect(response.status).toBe(200);
    expect(response.body.related).toBe(false);
    expect(mockPrisma.wordbank.updateMany).toHaveBeenCalled();
  });

  it("should fetch unrelated terms", async () => {
    mockPrisma.wordbank.findMany.mockResolvedValue([
      {
        termId: "term-1",
        term: {
          id: "term-1",
          term: "Roadmap",
          definition: "A strategic plan",
          topic: { name: "Product Management" },
        },
      },
    ]);

    const response = await request(app).get("/user/user-1/terms/unrelated");

    expect(response.status).toBe(200);
    expect(response.body.terms[0].term).toBe("Roadmap");
  });

  it("should reactivate a term", async () => {
    mockPrisma.wordbank.updateMany.mockResolvedValue({ count: 1 });

    const response = await request(app)
      .post("/user/user-1/terms/term-1/reactivate")
      .send();

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(mockPrisma.wordbank.updateMany).toHaveBeenCalled();
  });
});
