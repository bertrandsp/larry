import Foundation

// MARK: - Delivery Models

struct Delivery: Codable, Identifiable {
    let id: String
    let userId: String
    let termId: String
    let deliveredAt: Date
    let openedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, userId, termId, deliveredAt, openedAt
    }
}
