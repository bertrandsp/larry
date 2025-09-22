import Foundation

// MARK: - Delivery Models

struct Delivery: Codable, Identifiable {
    let id: String
    let userId: String
    let termId: String
    let deliveredAt: Date
    let openedAt: Date?
    let action: DeliveryAction
    
    enum CodingKeys: String, CodingKey {
        case id, userId, termId, deliveredAt, openedAt, action
    }
}

enum DeliveryAction: String, Codable, CaseIterable {
    case none = "NONE"
    case favorite = "FAVORITE"
    case learnAgain = "LEARN_AGAIN"
    case mastered = "MASTERED"
    
    var displayName: String {
        switch self {
        case .none:
            return "No Action"
        case .favorite:
            return "Favorite"
        case .learnAgain:
            return "Learn Again"
        case .mastered:
            return "Mastered"
        }
    }
    
    var icon: String {
        switch self {
        case .none:
            return "circle"
        case .favorite:
            return "heart.fill"
        case .learnAgain:
            return "arrow.clockwise"
        case .mastered:
            return "checkmark.circle.fill"
        }
    }
}
