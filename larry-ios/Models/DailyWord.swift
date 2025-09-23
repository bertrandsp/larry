//
//  DailyWord.swift
//  larry-ios
//
//  Created by AI Assistant on 9/15/25.
//

import Foundation

/// Represents a daily word delivery to the user
struct DailyWord: Codable, Identifiable {
    let id: String
    let userId: String
    let term: Term
    let deliveryDate: Date
    let isReview: Bool // true if this is a spaced repetition review, false if new
    let spacedRepetitionBucket: Int?
    let aiExplanation: String?
    let contextualExample: String?
    let createdAt: Date
    
    // User interaction tracking
    let userInteraction: DailyWordInteraction?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case term
        case deliveryDate = "delivery_date"
        case isReview = "is_review"
        case spacedRepetitionBucket = "spaced_repetition_bucket"
        case aiExplanation = "ai_explanation"
        case contextualExample = "contextual_example"
        case createdAt = "created_at"
        case userInteraction = "user_interaction"
    }
}

/// Represents user's interaction with a daily word
struct DailyWordInteraction: Codable {
    let dailyWordId: String
    let userId: String
    let viewedAt: Date?
    let completedAt: Date?
    var markedAsFavorite: Bool
    var markedForRelearning: Bool
    var markedAsMastered: Bool
    let timeSpentSeconds: Int?
    let aiChatUsed: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case dailyWordId = "daily_word_id"
        case userId = "user_id"
        case viewedAt = "viewed_at"
        case completedAt = "completed_at"
        case markedAsFavorite = "marked_as_favorite"
        case markedForRelearning = "marked_for_relearning"
        case markedAsMastered = "marked_as_mastered"
        case timeSpentSeconds = "time_spent_seconds"
        case aiChatUsed = "ai_chat_used"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Response model for the daily words API endpoint
struct DailyWordsResponse: Codable {
    let words: [DailyWord]
    let totalCount: Int
    let remainingToday: Int
    let nextDeliveryAt: Date?
    let streakCount: Int
    
    enum CodingKeys: String, CodingKey {
        case words
        case totalCount = "total_count"
        case remainingToday = "remaining_today"
        case nextDeliveryAt = "next_delivery_at"
        case streakCount = "streak_count"
    }
}

// MARK: - Preview Data
extension DailyWord {
    static let previewData = DailyWord(
        id: "preview-daily-word-1",
        userId: "preview-user-id",
        term: Term.previewData,
        deliveryDate: Date(),
        isReview: false,
        spacedRepetitionBucket: nil,
        aiExplanation: "This word is perfect for describing those wonderful moments when something good happens unexpectedly. In your software engineering career, you might experience serendipity when a bug leads you to discover a more elegant solution.",
        contextualExample: "The serendipitous encounter with a former colleague at the conference led to a job opportunity at their startup.",
        createdAt: Date(),
        userInteraction: DailyWordInteraction.previewData
    )
    
    static let previewReviewData = DailyWord(
        id: "preview-daily-word-2",
        userId: "preview-user-id",
        term: Term.previewDataList[1],
        deliveryDate: Date(),
        isReview: true,
        spacedRepetitionBucket: 2,
        aiExplanation: "You've seen this word before! Remember, ephemeral things don't last long - like the morning dew or a trending hashtag.",
        contextualExample: "The startup's success was ephemeral, lasting only until the market correction.",
        createdAt: Date(),
        userInteraction: nil
    )
    
    static let previewDataList: [DailyWord] = [
        previewData,
        previewReviewData
    ]
}

extension DailyWordInteraction {
    static let previewData = DailyWordInteraction(
        dailyWordId: "preview-daily-word-1",
        userId: "preview-user-id",
        viewedAt: Date().addingTimeInterval(-3600), // 1 hour ago
        completedAt: Date().addingTimeInterval(-1800), // 30 minutes ago
        markedAsFavorite: true,
        markedForRelearning: false,
        markedAsMastered: false,
        timeSpentSeconds: 180, // 3 minutes
        aiChatUsed: true,
        createdAt: Date().addingTimeInterval(-3600),
        updatedAt: Date().addingTimeInterval(-1800)
    )
}

extension DailyWordsResponse {
    static let previewData = DailyWordsResponse(
        words: DailyWord.previewDataList,
        totalCount: 2,
        remainingToday: 1,
        nextDeliveryAt: Calendar.current.date(byAdding: .hour, value: 8, to: Date()),
        streakCount: 7
    )
}
