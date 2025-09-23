//
//  User.swift
//  larry-ios
//
//  Created by AI Assistant on 9/15/25.
//

import Foundation

/// Represents a user in the Larry vocabulary learning app
struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String?
    let profileImageURL: String?
    let createdAt: Date
    let updatedAt: Date
    let onboardingCompleted: Bool
    let streakCount: Int
    let totalWordsLearned: Int
    let subscription: SubscriptionStatus
    
    enum SubscriptionStatus: String, Codable, CaseIterable {
        case free = "free"
        case plus = "plus"
        
        var displayName: String {
            switch self {
            case .free:
                return "Free"
            case .plus:
                return "Larry Plus"
            }
        }
        
        var wordsPerDay: Int {
            switch self {
            case .free:
                return 1
            case .plus:
                return 3
            }
        }
        
        var hasUnlimitedChat: Bool {
            switch self {
            case .free:
                return false
            case .plus:
                return true
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case profileImageURL = "profile_image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case onboardingCompleted = "onboarding_completed"
        case streakCount = "streak_count"
        case totalWordsLearned = "total_words_learned"
        case subscription
    }
}

// MARK: - Preview Data
extension User {
    static let previewData = User(
        id: "preview-user-id",
        email: "john.doe@example.com",
        name: "John Doe",
        profileImageURL: nil,
        createdAt: Date(),
        updatedAt: Date(),
        onboardingCompleted: true,
        streakCount: 7,
        totalWordsLearned: 42,
        subscription: .free
    )
    
    static let previewDataPlusUser = User(
        id: "preview-plus-user-id",
        email: "jane.smith@example.com",
        name: "Jane Smith",
        profileImageURL: nil,
        createdAt: Date(),
        updatedAt: Date(),
        onboardingCompleted: true,
        streakCount: 15,
        totalWordsLearned: 128,
        subscription: .plus
    )
}

