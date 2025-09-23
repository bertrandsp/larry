export interface TierConfig {
  name: string;
  maxTerms: number;
  maxFacts: number;
  maxTokens: number;
  features: string[];
  resetPeriod: 'daily' | 'weekly' | 'monthly' | 'never';
  maxRequestsPerPeriod: number;
  currentPeriodStart?: Date;
}

export const TIER_CONFIGS: Record<string, TierConfig> = {
  'free': {
    name: 'Free',
    maxTerms: 5,
    maxFacts: 3,
    maxTokens: 1000,
    features: ['Basic vocabulary', 'Limited facts', 'Standard definitions'],
    resetPeriod: 'daily',
    maxRequestsPerPeriod: 3
  },
  'basic': {
    name: 'Basic',
    maxTerms: 10,
    maxFacts: 5,
    maxTokens: 2000,
    features: ['Enhanced vocabulary', 'More facts', 'Examples included'],
    resetPeriod: 'weekly',
    maxRequestsPerPeriod: 10
  },
  'premium': {
    name: 'Premium',
    maxTerms: 25,
    maxFacts: 8,
    maxTokens: 4000,
    features: ['Comprehensive vocabulary', 'Rich facts', 'Advanced examples', 'Complexity analysis'],
    resetPeriod: 'monthly',
    maxRequestsPerPeriod: 50
  },
  'enterprise': {
    name: 'Enterprise',
    maxTerms: 50,
    maxFacts: 10,
    maxTokens: 8000,
    features: ['Maximum vocabulary', 'Full fact coverage', 'Premium examples', 'Advanced analytics', 'Priority processing'],
    resetPeriod: 'monthly',
    maxRequestsPerPeriod: 100
  }
};

export function getTierConfig(tier: string): TierConfig {
  return TIER_CONFIGS[tier] || TIER_CONFIGS['free'];
}

export function validateTierLimits(tier: string, requestedTerms: number, requestedFacts: number): {
  valid: boolean;
  maxTerms: number;
  maxFacts: number;
  adjustedTerms: number;
  adjustedFacts: number;
} {
  const config = getTierConfig(tier);
  
  const adjustedTerms = Math.min(requestedTerms, config.maxTerms);
  const adjustedFacts = Math.min(requestedFacts, config.maxFacts);
  
  return {
    valid: requestedTerms <= config.maxTerms && requestedFacts <= config.maxFacts,
    maxTerms: config.maxTerms,
    maxFacts: config.maxFacts,
    adjustedTerms,
    adjustedFacts
  };
}
