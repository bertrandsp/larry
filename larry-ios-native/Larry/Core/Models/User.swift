import Foundation

/// User model representing the authenticated user
struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String?
    let profileImageURL: String?
    let createdAt: Date
    let updatedAt: Date
    
    // User preferences and stats
    let streak: Int?
    let totalWordsLearned: Int?
    let subscriptionStatus: SubscriptionStatus?
    let onboardingCompleted: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case profileImageURL = "profile_image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case streak
        case totalWordsLearned = "total_words_learned"
        case subscriptionStatus = "subscription_status"
        case onboardingCompleted = "onboarding_completed"
    }
}

enum SubscriptionStatus: String, Codable, CaseIterable {
    case free = "free"
    case plus = "plus"
    case premium = "premium"
    
    var displayName: String {
        switch self {
        case .free:
            return "Free"
        case .plus:
            return "Larry Plus"
        case .premium:
            return "Larry Premium"
        }
    }
}

/// Authentication response from the backend
struct AuthResponse: Codable {
    let user: User
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case user
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}

/// Token refresh response
struct TokenRefreshResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}
