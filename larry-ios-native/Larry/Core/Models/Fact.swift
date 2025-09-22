import Foundation

/// Fact model representing interesting information about terms
struct Fact: Codable, Identifiable, Hashable {
    let id: String
    let content: String
    let type: FactType
    let source: String?
    let termId: String
    let createdAt: Date
    let updatedAt: Date
    
    // Engagement metrics
    let isInteresting: Bool?
    let likesCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case type
        case source
        case termId = "term_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isInteresting = "is_interesting"
        case likesCount = "likes_count"
    }
}

enum FactType: String, Codable, CaseIterable {
    case etymology = "etymology"
    case cultural = "cultural"
    case historical = "historical"
    case linguistic = "linguistic"
    case trivia = "trivia"
    case usage = "usage"
    case pronunciation = "pronunciation"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .etymology:
            return "Etymology"
        case .cultural:
            return "Cultural Context"
        case .historical:
            return "Historical Background"
        case .linguistic:
            return "Linguistic Note"
        case .trivia:
            return "Fun Fact"
        case .usage:
            return "Usage Note"
        case .pronunciation:
            return "Pronunciation Guide"
        case .other:
            return "Other"
        }
    }
    
    var iconSystemName: String {
        switch self {
        case .etymology:
            return "book.closed.fill"
        case .cultural:
            return "globe"
        case .historical:
            return "clock.fill"
        case .linguistic:
            return "textformat"
        case .trivia:
            return "lightbulb.fill"
        case .usage:
            return "quote.bubble.fill"
        case .pronunciation:
            return "speaker.wave.2.fill"
        case .other:
            return "info.circle.fill"
        }
    }
}
