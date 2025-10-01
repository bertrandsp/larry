import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { triggerPostOnboardingTermGeneration } from "../services/postOnboardingService";
import { prisma } from "../utils/prisma";
import * as openAiService from "../services/openAiService";
import * as generationLogService from "../services/generationLogService";

vi.mock("../utils/prisma", () => {
  const mock = {
    userTopic: {
      findMany: vi.fn(),
    },
    term: {
      count: vi.fn(),
      findFirst: vi.fn(),
      findMany: vi.fn(),
      create: vi.fn(),
    },
    wordbank: {
      findMany: vi.fn(),
      create: vi.fn(),
    },
    delivery: {
      create: vi.fn(),
    },
    user: {
      findUnique: vi.fn(),
    },
  };
  return { prisma: mock };
});

vi.mock("../services/openAiService", () => ({
  generateTermsForTopic: vi.fn(),
  generateDefinitionCard: vi.fn(),
}));

vi.mock("../services/generationLogService", () => ({
  logGeneration: vi.fn(),
}));

const mockPrisma = prisma as unknown as {
  userTopic: { findMany: ReturnType<typeof vi.fn> };
  term: {
    count: ReturnType<typeof vi.fn>;
    findFirst: ReturnType<typeof vi.fn>;
    findMany: ReturnType<typeof vi.fn>;
    create: ReturnType<typeof vi.fn>;
  };
  wordbank: {
    findMany: ReturnType<typeof vi.fn>;
    create: ReturnType<typeof vi.fn>;
  };
  delivery: { create: ReturnType<typeof vi.fn> };
  user: { findUnique: ReturnType<typeof vi.fn> };
};

const mockedOpenAi = openAiService as unknown as {
  generateTermsForTopic: ReturnType<typeof vi.fn>;
  generateDefinitionCard: ReturnType<typeof vi.fn>;
};

const mockedLogService = generationLogService as unknown as {
  logGeneration: ReturnType<typeof vi.fn>;
};

const USER_ID = "user-123";
const TOPIC_ID = "topic-123";

describe("postOnboardingService", () => {
  beforeEach(() => {
    vi.restoreAllMocks();

    mockPrisma.userTopic.findMany.mockResolvedValue([]);
    mockPrisma.term.count.mockResolvedValue(0);
    mockPrisma.term.findFirst.mockResolvedValue(null);
    mockPrisma.term.findMany.mockResolvedValue([]);
    mockPrisma.term.create.mockResolvedValue({ id: "generated-term", term: "term" });
    mockPrisma.wordbank.findMany.mockResolvedValue([]);
    mockPrisma.wordbank.create.mockResolvedValue({});
    mockPrisma.delivery.create.mockResolvedValue({});
    mockPrisma.user.findUnique.mockResolvedValue({ dailyWordGoal: 1 });

    mockedOpenAi.generateTermsForTopic.mockResolvedValue([]);
    mockedOpenAi.generateDefinitionCard.mockResolvedValue({
      term: "roadmap",
      definition: "definition",
      examples: ["example"],
    });
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  it("should generate terms for enabled topics and schedule deliveries", async () => {
    mockPrisma.userTopic.findMany.mockResolvedValue([
      {
        topicId: TOPIC_ID,
        topic: { id: TOPIC_ID, name: "Product Management", maxTerms: 10 },
      },
    ]);

    mockPrisma.term.count.mockResolvedValue(0);
    mockPrisma.term.findFirst.mockResolvedValue(null);
    mockPrisma.term.create
      .mockResolvedValueOnce({
        id: "term-1",
        term: "roadmap",
      })
      .mockResolvedValueOnce({
        id: "term-2",
        term: "backlog",
      });
    mockPrisma.term.findMany.mockResolvedValue([]);

    mockPrisma.wordbank.findMany.mockResolvedValue([]);
    mockPrisma.wordbank.create.mockResolvedValue({});
    mockPrisma.delivery.create.mockResolvedValue({});
    mockPrisma.user.findUnique.mockResolvedValue({ dailyWordGoal: 2 });

    mockedOpenAi.generateTermsForTopic.mockResolvedValue(["Roadmap", "Backlog"]);
    mockedOpenAi.generateDefinitionCard.mockResolvedValue({
      term: "roadmap",
      definition: "A strategic plan",
      examples: ["We created a roadmap"],
    });

    await triggerPostOnboardingTermGeneration(USER_ID);

    expect(mockedOpenAi.generateTermsForTopic).toHaveBeenCalledWith("Product Management");
    expect(mockedOpenAi.generateDefinitionCard).toHaveBeenCalledTimes(2);
    expect(mockPrisma.term.create).toHaveBeenCalledTimes(2);
    expect(mockPrisma.wordbank.create).toHaveBeenCalledTimes(0);
    expect(mockPrisma.delivery.create).toHaveBeenCalledTimes(0);
    expect(mockedLogService.logGeneration).toHaveBeenCalled();
  });

  it("should skip generation if topic already has max terms", async () => {
    mockPrisma.userTopic.findMany.mockResolvedValue([
      {
        topicId: TOPIC_ID,
        topic: { id: TOPIC_ID, name: "Product Management", maxTerms: 2 },
      },
    ]);

    mockPrisma.term.count.mockResolvedValue(2);
    mockPrisma.term.findMany.mockResolvedValue([]);

    await triggerPostOnboardingTermGeneration(USER_ID);

    expect(mockedOpenAi.generateTermsForTopic).not.toHaveBeenCalled();
    expect(mockPrisma.term.create).not.toHaveBeenCalled();
    expect(mockPrisma.wordbank.create).not.toHaveBeenCalled();
  });

  it("should not duplicate existing terms", async () => {
    mockPrisma.userTopic.findMany.mockResolvedValue([
      {
        topicId: TOPIC_ID,
        topic: { id: TOPIC_ID, name: "Product Management", maxTerms: 10 },
      },
    ]);

    mockPrisma.term.count.mockResolvedValue(0);
    mockPrisma.term.findFirst.mockResolvedValueOnce({ id: "existing" });
    mockPrisma.term.findFirst.mockResolvedValueOnce(null);

    mockedOpenAi.generateTermsForTopic.mockResolvedValue(["Roadmap", "Backlog"]);
    mockedOpenAi.generateDefinitionCard.mockResolvedValue({
      term: "roadmap",
      definition: "A strategic plan",
      examples: ["We created a roadmap"],
    });
    mockPrisma.wordbank.findMany.mockResolvedValue([]);
    mockPrisma.wordbank.create.mockResolvedValue({});
    mockPrisma.delivery.create.mockResolvedValue({});
    mockPrisma.user.findUnique.mockResolvedValue({ dailyWordGoal: 1 });

    await triggerPostOnboardingTermGeneration(USER_ID);

    expect(mockPrisma.term.create).toHaveBeenCalledTimes(1);
  });
});
