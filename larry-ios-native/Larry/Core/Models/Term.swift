import Foundation

/// Term model representing vocabulary words and their learning progress
struct Term: Codable, Identifiable, Hashable {
    let id: String
    let word: String
    let definition: String
    let pronunciation: String?
    let partOfSpeech: PartOfSpeech?
    let difficulty: DifficultyLevel
    let topicId: String
    let createdAt: Date
    let updatedAt: Date
    
    // Learning progress
    let bucket: SpacedRepetitionBucket
    let timesStudied: Int
    let timesCorrect: Int
    let lastStudiedAt: Date?
    let nextReviewAt: Date?
    let isFavorite: Bool
    let isMastered: Bool
    
    // Related content
    let examples: [String]?
    let synonyms: [String]?
    let antonyms: [String]?
    let etymology: String?
    let facts: [Fact]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case word
        case definition
        case pronunciation
        case partOfSpeech = "part_of_speech"
        case difficulty
        case topicId = "topic_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case bucket
        case timesStudied = "times_studied"
        case timesCorrect = "times_correct"
        case lastStudiedAt = "last_studied_at"
        case nextReviewAt = "next_review_at"
        case isFavorite = "is_favorite"
        case isMastered = "is_mastered"
        case examples
        case synonyms
        case antonyms
        case etymology
        case facts
    }
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
    case article = "article"
    case other = "other"
    
    var displayName: String {
        return rawValue.capitalized
    }
    
    var abbreviation: String {
        switch self {
        case .noun:
            return "n."
        case .verb:
            return "v."
        case .adjective:
            return "adj."
        case .adverb:
            return "adv."
        case .preposition:
            return "prep."
        case .conjunction:
            return "conj."
        case .interjection:
            return "interj."
        case .pronoun:
            return "pron."
        case .article:
            return "art."
        case .other:
            return ""
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
    
    var colorName: String {
        switch self {
        case .beginner:
            return "green"
        case .intermediate:
            return "yellow"
        case .advanced:
            return "orange"
        case .expert:
            return "red"
        }
    }
}

enum SpacedRepetitionBucket: Int, Codable, CaseIterable {
    case bucket1 = 1
    case bucket2 = 2
    case bucket3 = 3
    case bucket4 = 4
    case bucket5 = 5
    
    var reviewInterval: TimeInterval {
        switch self {
        case .bucket1:
            return 1 * 24 * 60 * 60 // 1 day
        case .bucket2:
            return 3 * 24 * 60 * 60 // 3 days
        case .bucket3:
            return 7 * 24 * 60 * 60 // 1 week
        case .bucket4:
            return 14 * 24 * 60 * 60 // 2 weeks
        case .bucket5:
            return 30 * 24 * 60 * 60 // 1 month
        }
    }
    
    var displayName: String {
        switch self {
        case .bucket1:
            return "New"
        case .bucket2:
            return "Learning"
        case .bucket3:
            return "Reviewing"
        case .bucket4:
            return "Familiar"
        case .bucket5:
            return "Known"
        }
    }
}
