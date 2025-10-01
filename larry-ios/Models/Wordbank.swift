import Foundation

// MARK: - Wordbank Models

struct Wordbank: Codable, Identifiable {
    let id: String
    let userId: String
    let termId: String
    let status: WordStatus
    let bucket: Int
    let lastReviewed: Date?
    let nextReview: Date?
    let reviewCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id, userId, termId, status, bucket, lastReviewed, nextReview, reviewCount
    }
}

enum WordStatus: String, Codable, CaseIterable {
    case learning = "LEARNING"
    case reviewing = "REVIEWING"
    case mastered = "MASTERED"
    case archived = "ARCHIVED"
    
    var displayName: String {
        switch self {
        case .learning:
            return "Learning"
        case .reviewing:
            return "Reviewing"
        case .mastered:
            return "Mastered"
        case .archived:
            return "Archived"
        }
    }
    
    var color: String {
        switch self {
        case .learning:
            return "blue"
        case .reviewing:
            return "orange"
        case .mastered:
            return "green"
        case .archived:
            return "gray"
        }
    }
    
    var icon: String {
        switch self {
        case .learning:
            return "book"
        case .reviewing:
            return "arrow.clockwise"
        case .mastered:
            return "checkmark.circle.fill"
        case .archived:
            return "archivebox"
        }
    }
}

// MARK: - First Daily Word Response

struct FirstDailyWordResponse: Codable {
    let success: Bool
    let firstVocabGenerated: Bool?
    let generating: Bool?
    let message: String?
    let estimatedTime: String?
    let retryAfter: Int?
    let redirect: String?
    let dailyWord: DailyWord?
    let userProgress: UserProgress?
    
    struct UserProgress: Codable {
        let wordsLearned: Int
        let streak: Int
        let level: String
    }
}

// MARK: - Enhanced Daily Word with Delivery Tracking

struct WordbankEnhancedDailyWord: Codable {
    let id: String
    let term: String
    let definition: String
    let example: String
    let category: String
    let complexityLevel: String
    let source: String
    let sourceUrl: String?
    let confidenceScore: Double
    let topic: String
    let facts: [WordbankFact]
    let delivery: WordbankDeliveryInfo?
    let wordbank: WordbankWordbankInfo?
    let isFirstWord: Bool?
    
    struct WordbankDeliveryInfo: Codable {
        let id: String
        let deliveredAt: Date
    }
    
    struct WordbankWordbankInfo: Codable {
        let id: String
        let bucket: Int
        let status: String
    }
    
    struct WordbankFact: Codable {
        let id: String
        let fact: String
        let category: String
    }
}

// MARK: - Delivery Action Request

struct DeliveryActionRequest: Codable {
    let deliveryId: String
    let action: DeliveryAction
    let wordbankId: String?
}

struct DeliveryActionResponse: Codable {
    let success: Bool
    let message: String
    let action: DeliveryAction
}
