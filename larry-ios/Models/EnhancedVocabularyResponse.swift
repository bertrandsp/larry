//
//  EnhancedVocabularyResponse.swift
//  larry-ios
//
//  Created by AI Assistant on 10/1/25.
//

import Foundation

/// Response model for enhanced vocabulary API endpoints
struct EnhancedFirstDailyWordResponse: Codable {
    let success: Bool
    let dailyWord: FirstDailyWord?
    let message: String?
}

/// Enhanced daily word model with rich vocabulary data
struct FirstDailyWord: Codable, Identifiable {
    let id: String
    let term: String
    let definition: String
    let example: String?
    let category: String?
    let complexityLevel: String?
    let source: String?
    let sourceUrl: String?
    let confidenceScore: Double
    let topic: TopicInfo?
    let facts: [VocabularyFact]
    let delivery: VocabularyDeliveryInfo
    let wordbank: VocabularyWordbankInfo
    let isFirstWord: Bool
    
    // Enhanced vocabulary fields
    let synonyms: [String]
    let antonyms: [String]
    let relatedTerms: [VocabularyRelatedTerm]
    let partOfSpeech: String?
    let difficulty: Int?
    let etymology: String?
    let pronunciation: String?
    let tags: [String]
    
    // Computed properties for UI
    var difficultyLevel: Term.DifficultyLevel {
        guard let difficulty = difficulty else { return .intermediate }
        switch difficulty {
        case 1: return .beginner
        case 2: return .intermediate
        case 3: return .advanced
        case 4, 5: return .expert
        default: return .intermediate
        }
    }
    
    var partOfSpeechEnum: Term.PartOfSpeech {
        guard let pos = partOfSpeech else { return .noun }
        return Term.PartOfSpeech(rawValue: pos) ?? .noun
    }
}

struct VocabularyFact: Codable {
    let id: String
    let fact: String
    let category: String?
}

struct VocabularyDeliveryInfo: Codable {
    let id: String
    let deliveredAt: String
}

struct VocabularyWordbankInfo: Codable {
    let id: String
    let bucket: Int
    let status: String
}

struct VocabularyRelatedTerm: Codable {
    let term: String
    let difference: String
}

// MARK: - Enhanced Daily Word Response (for returning users)
struct EnhancedDailyWordResponse: Codable {
    let success: Bool
    let dailyWord: EnhancedDailyWord?
    let message: String?
}

struct EnhancedDailyWord: Codable, Identifiable {
    let id: String
    let term: String
    let definition: String
    let example: String?
    let category: String?
    let complexityLevel: String?
    let source: String?
    let confidenceScore: Double
    let topic: String
    let facts: [VocabularyFact]
    let delivery: VocabularyDeliveryInfo
    let wordbank: VocabularyWordbankInfo
    let isReview: Bool
    
    // Enhanced vocabulary fields
    let synonyms: [String]
    let antonyms: [String]
    let relatedTerms: [VocabularyRelatedTerm]
    let partOfSpeech: String?
    let difficulty: Int?
    let etymology: String?
    let pronunciation: String?
    let tags: [String]
    
    // Computed properties for UI
    var difficultyLevel: Term.DifficultyLevel {
        guard let difficulty = difficulty else { return .intermediate }
        switch difficulty {
        case 1: return .beginner
        case 2: return .intermediate
        case 3: return .advanced
        case 4, 5: return .expert
        default: return .intermediate
        }
    }
    
    var partOfSpeechEnum: Term.PartOfSpeech {
        guard let pos = partOfSpeech else { return .noun }
        return Term.PartOfSpeech(rawValue: pos) ?? .noun
    }
}

// MARK: - Vocabulary Action Response
struct VocabularyActionResponse: Codable {
    let success: Bool
    let message: String?
    let action: String?
}

// MARK: - Preview Data
extension FirstDailyWord {
    static let previewData = FirstDailyWord(
        id: "preview-daily-word-1",
        term: "solidity",
        definition: "Solidity is a programming language for writing smart contracts on Ethereum.",
        example: "Developers use Solidity to create decentralized applications on the Ethereum blockchain.",
        category: "Programming",
        complexityLevel: "intermediate",
        source: "AI Generated",
        sourceUrl: nil,
        confidenceScore: 0.92,
        topic: TopicInfo(id: "blockchain-1", name: "Blockchain Development", slug: "blockchain-development"),
        facts: [
            VocabularyFact(id: "fact-1", fact: "Solidity was influenced by JavaScript, Python, and C++", category: "History"),
            VocabularyFact(id: "fact-2", fact: "First version was released in 2014", category: "Timeline")
        ],
        delivery: VocabularyDeliveryInfo(id: "delivery-1", deliveredAt: "2025-10-01T10:00:00Z"),
        wordbank: VocabularyWordbankInfo(id: "wordbank-1", bucket: 1, status: "LEARNING"),
        isFirstWord: true,
        synonyms: ["Ethereum language", "smart contract language"],
        antonyms: ["Bitcoin Script", "non-programmable"],
        relatedTerms: [
            VocabularyRelatedTerm(term: "Vyper", difference: "Another Ethereum smart contract language, designed to be more secure")
        ],
        partOfSpeech: "noun",
        difficulty: 2,
        etymology: "Derived from 'solid' + 'ity', emphasizing reliability",
        pronunciation: "/səˈlɪdɪti/",
        tags: ["Blockchain Development", "Programming", "AI Generated"]
    )
}

extension EnhancedDailyWord {
    static let previewData = EnhancedDailyWord(
        id: "preview-enhanced-word-1",
        term: "ephemeral",
        definition: "Lasting for a very short time",
        example: "The beauty of cherry blossoms is ephemeral, lasting only a few weeks each spring.",
        category: "Vocabulary",
        complexityLevel: "advanced",
        source: "AI Generated",
        confidenceScore: 0.89,
        topic: "Nature",
        facts: [
            VocabularyFact(id: "fact-1", fact: "From Greek ephēmeros, meaning 'lasting only a day'", category: "Etymology")
        ],
        delivery: VocabularyDeliveryInfo(id: "delivery-2", deliveredAt: "2025-10-01T09:00:00Z"),
        wordbank: VocabularyWordbankInfo(id: "wordbank-2", bucket: 2, status: "LEARNING"),
        isReview: false,
        synonyms: ["transient", "fleeting", "temporary"],
        antonyms: ["permanent", "enduring", "lasting"],
        relatedTerms: [
            VocabularyRelatedTerm(term: "transitory", difference: "Similar meaning but more formal"),
            VocabularyRelatedTerm(term: "momentary", difference: "Emphasizes very brief duration")
        ],
        partOfSpeech: "adjective",
        difficulty: 3,
        etymology: "From Greek ephēmeros, meaning 'lasting only a day'",
        pronunciation: "/əˈfem(ə)rəl/",
        tags: ["Nature", "Philosophy", "AI Generated"]
    )
}