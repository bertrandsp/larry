// JavaScript version of tier config for testing
const TIER_CONFIGS = {
  'free': {
    name: 'Free',
    maxTerms: 5,
    maxFacts: 3,
    maxTokens: 1000,
    features: ['Basic vocabulary', 'Limited facts', 'Standard definitions']
  },
  'basic': {
    name: 'Basic',
    maxTerms: 10,
    maxFacts: 5,
    maxTokens: 2000,
    features: ['Enhanced vocabulary', 'More facts', 'Examples included']
  },
  'premium': {
    name: 'Premium',
    maxTerms: 25,
    maxFacts: 8,
    maxTokens: 4000,
    features: ['Comprehensive vocabulary', 'Rich facts', 'Advanced examples', 'Complexity analysis']
  },
  'enterprise': {
    name: 'Enterprise',
    maxTerms: 50,
    maxFacts: 10,
    maxTokens: 8000,
    features: ['Maximum vocabulary', 'Full fact coverage', 'Premium examples', 'Advanced analytics', 'Priority processing']
  }
};

function getTierConfig(tier) {
  return TIER_CONFIGS[tier] || TIER_CONFIGS['free'];
}

module.exports = { getTierConfig, TIER_CONFIGS };
