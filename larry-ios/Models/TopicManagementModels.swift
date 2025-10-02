//
//  TopicManagementModels.swift
//  larry-ios
//
//  Created by AI Assistant on 10/2/25.
//

import Foundation

// MARK: - API Response Models

/// Response model for available topics endpoint
struct AvailableTopicsResponse: Codable {
    let success: Bool
    let topics: [AvailableTopic]
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case success
        case topics
        case totalCount
    }
}

/// Represents an available topic that can be added by users
struct AvailableTopic: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let category: String?
    let isActive: Bool
    let termCount: Int
    let userCount: Int
    let isPopular: Bool
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case category
        case isActive = "isActive"
        case termCount = "termCount"
        case userCount = "userCount"
        case isPopular = "isPopular"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
    }
    
    /// Convert to Topic model for UI compatibility
    func toTopic() -> Topic {
        let topicCategory = Topic.TopicCategory(rawValue: category?.lowercased() ?? "other") ?? .other
        
        return Topic(
            id: id,
            name: name,
            description: description ?? "\(name) vocabulary and terminology",
            category: topicCategory,
            iconName: topicCategory.systemImageName,
            colorHex: nil,
            isActive: isActive,
            termCount: termCount,
            createdAt: ISO8601DateFormatter().date(from: createdAt) ?? Date(),
            updatedAt: ISO8601DateFormatter().date(from: updatedAt) ?? Date(),
            userTopicWeight: nil
        )
    }
}

/// Response model for user topics endpoint
struct UserTopicsResponse: Codable {
    let success: Bool
    let topics: [UserTopic]
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case success
        case topics
        case totalCount = "totalCount"
    }
}

/// Represents a topic that belongs to a user
struct UserTopic: Codable, Identifiable {
    let id: String
    let topicId: String
    let name: String
    let weight: Int
    let enabled: Bool
    let termCount: Int
    let category: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case topicId = "topicId"
        case name
        case weight
        case enabled
        case termCount = "termCount"
        case category
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
    }
    
    /// Convert to Topic model for UI compatibility
    func toTopic() -> Topic {
        let topicCategory = Topic.TopicCategory(rawValue: category?.lowercased() ?? "other") ?? .other
        
        let userWeight = UserTopicWeight(
            topicId: topicId,
            userId: "current-user", // This would come from auth context
            weight: weight,
            isBoostActive: false,
            boostEndDate: nil,
            createdAt: ISO8601DateFormatter().date(from: createdAt ?? "") ?? Date(),
            updatedAt: ISO8601DateFormatter().date(from: updatedAt ?? "") ?? Date()
        )
        
        return Topic(
            id: topicId,
            name: name,
            description: "\(name) vocabulary and terminology",
            category: topicCategory,
            iconName: topicCategory.systemImageName,
            colorHex: nil,
            isActive: enabled,
            termCount: termCount,
            createdAt: ISO8601DateFormatter().date(from: createdAt ?? "") ?? Date(),
            updatedAt: ISO8601DateFormatter().date(from: updatedAt ?? "") ?? Date(),
            userTopicWeight: userWeight
        )
    }
}

/// Response model for adding a topic to user
struct AddTopicResponse: Codable {
    let success: Bool
    let userTopic: AddedUserTopic
}

/// Represents a newly added user topic
struct AddedUserTopic: Codable {
    let id: String
    let topicId: String
    let userId: String
    let weight: Int
    let enabled: Bool
    let topic: AddedTopicDetails
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case topicId = "topicId"
        case userId = "userId"
        case weight
        case enabled
        case topic
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
    }
}

/// Topic details in add topic response
struct AddedTopicDetails: Codable {
    let id: String
    let name: String
    let description: String?
    let category: String?
    let termCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case category
        case termCount = "termCount"
    }
}

/// Response model for updating topic
struct UpdateTopicResponse: Codable {
    let success: Bool
    let userTopic: UserTopic
}

// MARK: - Request Models

/// Request model for adding a topic to user
struct AddTopicRequest: Codable {
    let topicId: String
    let weight: Int
    
    enum CodingKeys: String, CodingKey {
        case topicId = "topicId"
        case weight
    }
}

/// Request model for updating topic weight
struct UpdateTopicWeightRequest: Codable {
    let weight: Int
}

// MARK: - UI Helper Models

/// Represents the state of topic management operations
enum TopicManagementState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}

/// Represents different topic management actions
enum TopicManagementAction {
    case loadAvailableTopics
    case loadUserTopics
    case addTopic(String, Int) // topicId, weight
    case updateWeight(String, Int) // userTopicId, weight
    case toggleTopic(String) // userTopicId
    case removeTopic(String) // userTopicId
}

// MARK: - Extensions for Preview Data

extension AvailableTopic {
    static let previewData = AvailableTopic(
        id: "preview-available-topic-1",
        name: "Machine Learning",
        description: "Artificial intelligence, neural networks, and data science terminology",
        category: "technology",
        isActive: true,
        termCount: 245,
        userCount: 1250,
        isPopular: true,
        createdAt: "2024-01-15T10:30:00Z",
        updatedAt: "2024-09-20T14:45:00Z"
    )
    
    static let previewDataList: [AvailableTopic] = [
        previewData,
        AvailableTopic(
            id: "preview-available-topic-2",
            name: "Sustainable Living",
            description: "Environmental terminology, green practices, and eco-friendly concepts",
            category: "lifestyle",
            isActive: true,
            termCount: 156,
            userCount: 890,
            isPopular: false,
            createdAt: "2024-02-10T09:15:00Z",
            updatedAt: "2024-09-18T11:20:00Z"
        ),
        AvailableTopic(
            id: "preview-available-topic-3",
            name: "Digital Marketing",
            description: "Online marketing, social media, and advertising terminology",
            category: "career",
            isActive: true,
            termCount: 198,
            userCount: 2100,
            isPopular: true,
            createdAt: "2024-01-20T16:45:00Z",
            updatedAt: "2024-09-22T08:30:00Z"
        )
    ]
}

extension UserTopic {
    static let previewData = UserTopic(
        id: "preview-user-topic-1",
        topicId: "preview-topic-1",
        name: "Software Engineering",
        weight: 75,
        enabled: true,
        termCount: 156,
        category: "technology",
        createdAt: "2024-08-15T10:30:00Z",
        updatedAt: "2024-09-20T14:45:00Z"
    )
    
    static let previewDataList: [UserTopic] = [
        previewData,
        UserTopic(
            id: "preview-user-topic-2",
            topicId: "preview-topic-2",
            name: "Travel Photography",
            weight: 50,
            enabled: true,
            termCount: 89,
            category: "travel",
            createdAt: "2024-08-20T12:15:00Z",
            updatedAt: "2024-09-18T16:20:00Z"
        ),
        UserTopic(
            id: "preview-user-topic-3",
            topicId: "preview-topic-3",
            name: "Creative Writing",
            weight: 25,
            enabled: false,
            termCount: 203,
            category: "arts",
            createdAt: "2024-07-10T14:30:00Z",
            updatedAt: "2024-09-15T09:45:00Z"
        )
    ]
}
