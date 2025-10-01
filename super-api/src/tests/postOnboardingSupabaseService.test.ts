import { describe, it, expect, vi } from "vitest";

vi.mock("../config/supabase", () => ({
  supabase: null,
}));

import { triggerSupabasePostOnboarding } from "../services/postOnboardingSupabaseService";

vi.mock("../services/generationLogService", () => ({
  logGeneration: vi.fn(),
}));

vi.mock("../services/openAiService", () => ({
  generateTermsForTopic: vi.fn(),
  generateDefinitionCard: vi.fn(),
}));

describe("triggerSupabasePostOnboarding", () => {
  it("returns when Supabase client is not configured", async () => {
    await triggerSupabasePostOnboarding("user-123");
    expect(true).toBe(true);
  });
});
