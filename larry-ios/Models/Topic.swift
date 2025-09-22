//
//  Topic.swift
//  larry-ios
//
//  Created by AI Assistant on 9/15/25.
//

import Foundation

/// Represents a topic/interest area in the Larry app
struct Topic: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let category: TopicCategory
    let iconName: String?
    let colorHex: String?
    let isActive: Bool
    let termCount: Int
    let createdAt: Date
    let updatedAt: Date
    
    // User-specific properties
    let userTopicWeight: UserTopicWeight?
    
    enum TopicCategory: String, Codable, CaseIterable {
        case career = "career"
        case hobbies = "hobbies"
        case travel = "travel"
        case academic = "academic"
        case lifestyle = "lifestyle"
        case technology = "technology"
        case arts = "arts"
        case sports = "sports"
        case health = "health"
        case finance = "finance"
        case science = "science"
        case history = "history"
        case culture = "culture"
        case language = "language"
        case other = "other"
        
        var displayName: String {
            switch self {
            case .career: return "Career & Professional"
            case .hobbies: return "Hobbies & Interests"
            case .travel: return "Travel & Places"
            case .academic: return "Academic & Education"
            case .lifestyle: return "Lifestyle & Personal"
            case .technology: return "Technology & Digital"
            case .arts: return "Arts & Culture"
            case .sports: return "Sports & Recreation"
            case .health: return "Health & Wellness"
            case .finance: return "Finance & Business"
            case .science: return "Science & Research"
            case .history: return "History & Heritage"
            case .culture: return "Culture & Society"
            case .language: return "Language & Literature"
            case .other: return "Other"
            }
        }
        
        var systemImageName: String {
            switch self {
            case .career: return "briefcase.fill"
            case .hobbies: return "heart.fill"
            case .travel: return "airplane"
            case .academic: return "graduationcap.fill"
            case .lifestyle: return "house.fill"
            case .technology: return "laptopcomputer"
            case .arts: return "paintbrush.fill"
            case .sports: return "sportscourt.fill"
            case .health: return "heart.text.square.fill"
            case .finance: return "dollarsign.circle.fill"
            case .science: return "flask.fill"
            case .history: return "clock.fill"
            case .culture: return "globe"
            case .language: return "textbook.fill"
            case .other: return "ellipsis.circle.fill"
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case category
        case iconName = "icon_name"
        case colorHex = "color_hex"
        case isActive = "is_active"
        case termCount = "term_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userTopicWeight = "user_topic_weight"
    }
}

/// Represents user's weight/preference for a specific topic
struct UserTopicWeight: Codable {
    let topicId: String
    let userId: String
    let weight: Int // 0-100 percentage
    let isBoostActive: Bool
    let boostEndDate: Date?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case topicId = "topic_id"
        case userId = "user_id"
        case weight
        case isBoostActive = "is_boost_active"
        case boostEndDate = "boost_end_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Preview Data
extension Topic {
    static let previewData = Topic(
        id: "preview-topic-1",
        name: "Software Engineering",
        description: "Programming languages, frameworks, development methodologies, and technical concepts",
        category: .technology,
        iconName: "laptopcomputer",
        colorHex: "#007AFF",
        isActive: true,
        termCount: 156,
        createdAt: Date(),
        updatedAt: Date(),
        userTopicWeight: UserTopicWeight.previewData
    )
    
    static let previewDataList: [Topic] = [
        previewData,
        Topic(
            id: "preview-topic-2",
            name: "Travel & Tourism",
            description: "Travel terminology, cultural concepts, and location-specific vocabulary",
            category: .travel,
            iconName: "airplane",
            colorHex: "#34C759",
            isActive: true,
            termCount: 89,
            createdAt: Date(),
            updatedAt: Date(),
            userTopicWeight: UserTopicWeight(
                topicId: "preview-topic-2",
                userId: "preview-user-id",
                weight: 25,
                isBoostActive: true,
                boostEndDate: Date().addingTimeInterval(2592000), // 30 days from now
                createdAt: Date(),
                updatedAt: Date()
            )
        ),
        Topic(
            id: "preview-topic-3",
            name: "Literature & Writing",
            description: "Literary terms, writing techniques, and language arts vocabulary",
            category: .arts,
            iconName: "textbook.fill",
            colorHex: "#FF9500",
            isActive: true,
            termCount: 203,
            createdAt: Date(),
            updatedAt: Date(),
            userTopicWeight: UserTopicWeight(
                topicId: "preview-topic-3",
                userId: "preview-user-id",
                weight: 15,
                isBoostActive: false,
                boostEndDate: nil,
                createdAt: Date(),
                updatedAt: Date()
            )
        )
    ]
}

extension UserTopicWeight {
    static let previewData = UserTopicWeight(
        topicId: "preview-topic-1",
        userId: "preview-user-id",
        weight: 60,
        isBoostActive: false,
        boostEndDate: nil,
        createdAt: Date(),
        updatedAt: Date()
    )
}

