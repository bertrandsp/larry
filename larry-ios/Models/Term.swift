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
    let word: String
    let definition: String
    let pronunciation: String?
    let partOfSpeech: PartOfSpeech
    let difficulty: DifficultyLevel
    let exampleSentence: String?
    let etymology: String?
    let synonyms: [String]
    let antonyms: [String]
    let relatedTerms: [String]
    let topicIds: [String]
    let createdAt: Date
    let updatedAt: Date
    
    // User-specific properties
    let userProgress: UserTermProgress?
    
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
        case word
        case definition
        case pronunciation
        case partOfSpeech = "part_of_speech"
        case difficulty
        case exampleSentence = "example_sentence"
        case etymology
        case synonyms
        case antonyms
        case relatedTerms = "related_terms"
        case topicIds = "topic_ids"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userProgress = "user_progress"
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
        word: "serendipity",
        definition: "The occurrence and development of events by chance in a happy or beneficial way",
        pronunciation: "/ˌserənˈdipədē/",
        partOfSpeech: .noun,
        difficulty: .intermediate,
        exampleSentence: "A fortunate stroke of serendipity led to their groundbreaking discovery.",
        etymology: "Coined by Horace Walpole in 1754, from the Persian fairy tale 'The Three Princes of Serendip'",
        synonyms: ["chance", "fortune", "luck"],
        antonyms: ["misfortune", "bad luck"],
        relatedTerms: ["fortuitous", "providential"],
        topicIds: ["literature", "philosophy"],
        createdAt: Date(),
        updatedAt: Date(),
        userProgress: UserTermProgress.previewData
    )
    
    static let previewDataList: [Term] = [
        previewData,
        Term(
            id: "preview-term-2",
            word: "ephemeral",
            definition: "Lasting for a very short time",
            pronunciation: "/əˈfem(ə)rəl/",
            partOfSpeech: .adjective,
            difficulty: .advanced,
            exampleSentence: "The beauty of cherry blossoms is ephemeral, lasting only a few weeks each spring.",
            etymology: "From Greek ephēmeros, meaning 'lasting only a day'",
            synonyms: ["transient", "fleeting", "temporary"],
            antonyms: ["permanent", "enduring", "lasting"],
            relatedTerms: ["transitory", "momentary"],
            topicIds: ["nature", "philosophy"],
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

