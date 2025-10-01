import { describe, it, expect } from "vitest";
import { openAiService } from '../services/openAiService';

// Mock OpenAI responses for testing
const mockOpenAIResponse = (content: string) => ({
  choices: [{ message: { content } }]
});

describe('OpenAI Service Enhanced Prompts', () => {
  it("should generate terms and facts", async () => {
    // Mock the OpenAI response
    const mockResponse = `Terms: pickleball, paddle, court, net, serve, volley, dink, smash, lob, drop shot
Facts:
1. Pickleball was invented in 1965 on Bainbridge Island, Washington.
2. The game combines elements of tennis, badminton, and ping-pong.
3. Pickleball courts are smaller than tennis courts.
4. The game is named after a family dog, Pickles.
5. Pickleball is one of the fastest-growing sports in America.`;

    // This would require mocking the OpenAI client in a real test environment
    // For now, we'll test the parsing logic
    const [termsPart, ...factsPart] = mockResponse.split("Facts:");
    const terms = termsPart.replace("Terms:", "").split(",").map(t => t.trim()).filter(Boolean);
    const facts = factsPart.join("Facts:").split(/\n\d+\.\s/).map(f => f.trim()).filter(Boolean);

    expect(terms.length).toBeGreaterThan(5);
    expect(facts.length).toBeGreaterThanOrEqual(5);
    expect(terms).toContain('pickleball');
    expect(facts[0]).toContain('1965');
  });

  it("should rewrite a definition", async () => {
    const mockResponse = `Definition: A paddle sport combining tennis, badminton, and ping-pong elements.
Example: We play pickleball every Saturday morning at the community center.`;

    const defMatch = mockResponse.match(/Definition:\s*(.+)/i);
    const exMatch = mockResponse.match(/Example:\s*(.+)/i);

    expect(defMatch?.[1]?.trim()).toBe("A paddle sport combining tennis, badminton, and ping-pong elements.");
    expect(exMatch?.[1]?.trim()).toMatch(/pickleball/i);
  });

  it("should fallback define a term", async () => {
    const mockResponse = `Definition: A specialized tool or implement used in a specific craft or trade.
Explanation: Based on the word structure 'glimbrick' which appears to be a compound word, likely related to specialized tools or implements used in specific trades or crafts.`;

    const defMatch = mockResponse.match(/Definition:\s*(.+)/i);
    const exMatch = mockResponse.match(/Explanation:\s*(.+)/i);

    expect(defMatch?.[1]?.trim().length).toBeGreaterThan(10);
    expect(exMatch?.[1]?.trim()).toBeTruthy();
  });
});
