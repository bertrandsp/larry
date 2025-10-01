//
//  Term.swift
//  larry-ios
//
//  Created by AI Assistant on 9/15/25.
//

import Foundation

/// Represents a vocabulary term in the Larry app
struct Term: Codable, Identifiable {
    let id: String
    let term: String // Changed from 'word' to match backend
    let definition: String
    let example: String? // Changed from 'exampleSentence' to match backend
    let pronunciation: String?
    let partOfSpeech: String? // Changed from enum to optional String to match backend
    let difficulty: Int? // Changed from enum to optional Int to match backend
    let etymology: String?
    let synonyms: [String]
    let antonyms: [String]
    let relatedTerms: [VocabularyRelatedTerm] // Enhanced to include difference explanations
    let tags: [String] // Added tags field
    let category: String?
    let complexityLevel: String?
    let source: String?
    let confidenceScore: Double?
    let topicId: String? // Changed from topicIds array to single topicId
    let createdAt: Date?
    let updatedAt: Date?
    
    // User-specific properties
    let userProgress: UserTermProgress?
    
    // Computed properties for backward compatibility
    var word: String { term }
    var exampleSentence: String? { example }
    var difficultyLevel: DifficultyLevel {
        guard let difficulty = difficulty else { return .intermediate }
        switch difficulty {
        case 1: return .beginner
        case 2: return .intermediate
        case 3: return .advanced
        case 4, 5: return .expert
        default: return .intermediate
        }
    }
    var partOfSpeechEnum: PartOfSpeech {
        guard let pos = partOfSpeech else { return .noun }
        return PartOfSpeech(rawValue: pos) ?? .noun
    }
    
    enum PartOfSpeech: String, Codable, CaseIterable {
        case noun = "noun"
        case verb = "verb"
        case adjective = "adjective"
        case adverb = "adverb"
        case preposition = "preposition"
        case conjunction = "conjunction"
        case interjection = "interjection"
        case pronoun = "pronoun"
        case determiner = "determiner"
        
        var displayName: String {
            return rawValue.capitalized
        }
        
        var abbreviation: String {
            switch self {
            case .noun: return "n."
            case .verb: return "v."
            case .adjective: return "adj."
            case .adverb: return "adv."
            case .preposition: return "prep."
            case .conjunction: return "conj."
            case .interjection: return "int."
            case .pronoun: return "pron."
            case .determiner: return "det."
            }
        }
    }
    
    enum DifficultyLevel: String, Codable, CaseIterable {
        case beginner = "beginner"
        case intermediate = "intermediate"
        case advanced = "advanced"
        case expert = "expert"
        
        var displayName: String {
            return rawValue.capitalized
        }
        
        var color: String {
            switch self {
            case .beginner: return "green"
            case .intermediate: return "yellow"
            case .advanced: return "orange"
            case .expert: return "red"
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case term
        case definition
        case example
        case pronunciation
        case partOfSpeech
        case difficulty
        case etymology
        case synonyms
        case antonyms
        case relatedTerms
        case tags
        case category
        case complexityLevel
        case source
        case confidenceScore
        case topicId
        case createdAt
        case updatedAt
        case userProgress
    }
}

/// Represents user's progress with a specific term
struct UserTermProgress: Codable {
    let termId: String
    let userId: String
    let masteryLevel: MasteryLevel
    let reviewCount: Int
    let correctCount: Int
    let lastReviewedAt: Date?
    let nextReviewAt: Date?
    let spacedRepetitionBucket: Int
    let isFavorited: Bool
    let wantsToRelearn: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum MasteryLevel: String, Codable, CaseIterable {
        case new = "new"
        case learning = "learning"
        case familiar = "familiar"
        case mastered = "mastered"
        
        var displayName: String {
            return rawValue.capitalized
        }
        
        var progressValue: Double {
            switch self {
            case .new: return 0.0
            case .learning: return 0.33
            case .familiar: return 0.66
            case .mastered: return 1.0
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case termId = "term_id"
        case userId = "user_id"
        case masteryLevel = "mastery_level"
        case reviewCount = "review_count"
        case correctCount = "correct_count"
        case lastReviewedAt = "last_reviewed_at"
        case nextReviewAt = "next_review_at"
        case spacedRepetitionBucket = "spaced_repetition_bucket"
        case isFavorited = "is_favorited"
        case wantsToRelearn = "wants_to_relearn"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}


// MARK: - Preview Data
extension Term {
    static let previewData = Term(
        id: "preview-term-id",
        term: "serendipity",
        definition: "The occurrence and development of events by chance in a happy or beneficial way",
        example: "A fortunate stroke of serendipity led to their groundbreaking discovery.",
        pronunciation: "/ˌserənˈdipədē/",
        partOfSpeech: "noun",
        difficulty: 2,
        etymology: "Coined by Horace Walpole in 1754, from the Persian fairy tale 'The Three Princes of Serendip'",
        synonyms: ["chance", "fortune", "luck"],
        antonyms: ["misfortune", "bad luck"],
        relatedTerms: [
            VocabularyRelatedTerm(term: "fortuitous", difference: "More formal synonym meaning happening by chance"),
            VocabularyRelatedTerm(term: "providential", difference: "Implies divine intervention rather than pure chance")
        ],
        tags: ["literature", "philosophy"],
        category: "Vocabulary",
        complexityLevel: "intermediate",
        source: "AI Generated",
        confidenceScore: 0.95,
        topicId: "literature",
        createdAt: Date(),
        updatedAt: Date(),
        userProgress: UserTermProgress.previewData
    )
    
    static let previewDataList: [Term] = [
        previewData,
        Term(
            id: "preview-term-2",
            term: "ephemeral",
            definition: "Lasting for a very short time",
            example: "The beauty of cherry blossoms is ephemeral, lasting only a few weeks each spring.",
            pronunciation: "/əˈfem(ə)rəl/",
            partOfSpeech: "adjective",
            difficulty: 3,
            etymology: "From Greek ephēmeros, meaning 'lasting only a day'",
            synonyms: ["transient", "fleeting", "temporary"],
            antonyms: ["permanent", "enduring", "lasting"],
            relatedTerms: [
                VocabularyRelatedTerm(term: "transitory", difference: "Similar meaning but more formal"),
                VocabularyRelatedTerm(term: "momentary", difference: "Emphasizes very brief duration")
            ],
            tags: ["nature", "philosophy"],
            category: "Vocabulary",
            complexityLevel: "advanced",
            source: "AI Generated",
            confidenceScore: 0.92,
            topicId: "nature",
            createdAt: Date(),
            updatedAt: Date(),
            userProgress: nil
        )
    ]
}

extension UserTermProgress {
    static let previewData = UserTermProgress(
        termId: "preview-term-id",
        userId: "preview-user-id",
        masteryLevel: .learning,
        reviewCount: 3,
        correctCount: 2,
        lastReviewedAt: Date().addingTimeInterval(-86400), // 1 day ago
        nextReviewAt: Date().addingTimeInterval(172800), // 2 days from now
        spacedRepetitionBucket: 2,
        isFavorited: true,
        wantsToRelearn: false,
        createdAt: Date().addingTimeInterval(-604800), // 1 week ago
        updatedAt: Date().addingTimeInterval(-86400) // 1 day ago
    )
}

