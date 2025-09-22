import Foundation

/// Topic model representing user interests and learning areas
struct Topic: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let description: String?
    let category: TopicCategory
    let iconName: String?
    let colorHex: String?
    let isActive: Bool
    let weight: Double // 0.0 to 1.0 representing user's interest level
    let createdAt: Date
    let updatedAt: Date
    
    // Topic statistics
    let totalTerms: Int?
    let masteredTerms: Int?
    let lastStudiedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case category
        case iconName = "icon_name"
        case colorHex = "color_hex"
        case isActive = "is_active"
        case weight
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case totalTerms = "total_terms"
        case masteredTerms = "mastered_terms"
        case lastStudiedAt = "last_studied_at"
    }
}

enum TopicCategory: String, Codable, CaseIterable {
    case career = "career"
    case hobby = "hobby"
    case travel = "travel"
    case community = "community"
    case general = "general"
    case custom = "custom"
    
    var displayName: String {
        switch self {
        case .career:
            return "Career"
        case .hobby:
            return "Hobby"
        case .travel:
            return "Travel"
        case .community:
            return "Community"
        case .general:
            return "General"
        case .custom:
            return "Custom"
        }
    }
    
    var iconSystemName: String {
        switch self {
        case .career:
            return "briefcase.fill"
        case .hobby:
            return "heart.fill"
        case .travel:
            return "airplane"
        case .community:
            return "person.2.fill"
        case .general:
            return "book.fill"
        case .custom:
            return "star.fill"
        }
    }
}

/// Request model for updating topic weights
struct TopicWeightUpdate: Codable {
    let topicId: String
    let weight: Double
    
    enum CodingKeys: String, CodingKey {
        case topicId = "topic_id"
        case weight
    }
}

/// Response model for topic weight updates
struct TopicWeightResponse: Codable {
    let topics: [Topic]
    let message: String?
}
