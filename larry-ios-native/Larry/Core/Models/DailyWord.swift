import Foundation

/// DailyWord model representing the daily vocabulary delivery
struct DailyWord: Codable, Identifiable {
    let id: String
    let term: Term
    let deliveryDate: Date
    let isCompleted: Bool
    let completedAt: Date?
    let userAction: UserAction?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case term
        case deliveryDate = "delivery_date"
        case isCompleted = "is_completed"
        case completedAt = "completed_at"
        case userAction = "user_action"
        case createdAt = "created_at"
    }
}

/// User actions that can be taken on a daily word
enum UserAction: String, Codable, CaseIterable {
    case favorite = "favorite"
    case learnAgain = "learn_again"
    case mastered = "mastered"
    case skip = "skip"
    
    var displayName: String {
        switch self {
        case .favorite:
            return "Add to Favorites"
        case .learnAgain:
            return "Learn Again"
        case .mastered:
            return "Mark as Mastered"
        case .skip:
            return "Skip"
        }
    }
    
    var iconSystemName: String {
        switch self {
        case .favorite:
            return "heart.fill"
        case .learnAgain:
            return "arrow.clockwise"
        case .mastered:
            return "checkmark.circle.fill"
        case .skip:
            return "forward.fill"
        }
    }
}

/// Request model for daily word actions
struct DailyWordActionRequest: Codable {
    let action: UserAction
    let dailyWordId: String
    
    enum CodingKeys: String, CodingKey {
        case action
        case dailyWordId = "daily_word_id"
    }
}

/// Response model for daily word delivery
struct DailyWordResponse: Codable {
    let dailyWords: [DailyWord]
    let streak: Int
    let nextDeliveryAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case dailyWords = "daily_words"
        case streak
        case nextDeliveryAt = "next_delivery_at"
    }
}

/// Statistics model for user progress
struct LearningStats: Codable {
    let currentStreak: Int
    let longestStreak: Int
    let totalWordsLearned: Int
    let totalWordsMastered: Int
    let favoriteWords: Int
    let averageAccuracy: Double
    let weeklyProgress: [WeeklyProgress]
    
    enum CodingKeys: String, CodingKey {
        case currentStreak = "current_streak"
        case longestStreak = "longest_streak"
        case totalWordsLearned = "total_words_learned"
        case totalWordsMastered = "total_words_mastered"
        case favoriteWords = "favorite_words"
        case averageAccuracy = "average_accuracy"
        case weeklyProgress = "weekly_progress"
    }
}

struct WeeklyProgress: Codable, Identifiable {
    let id = UUID()
    let week: String
    let wordsLearned: Int
    let accuracy: Double
    
    enum CodingKeys: String, CodingKey {
        case week
        case wordsLearned = "words_learned"
        case accuracy
    }
}
