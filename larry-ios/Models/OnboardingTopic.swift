//
//  OnboardingTopic.swift
//  larry-ios
//
//  Created by AI Assistant on 9/29/25.
//

import Foundation

/// Simple topic model for onboarding API responses
struct OnboardingTopic: Codable, Identifiable {
    let id: String
    let name: String
    let canonicalSetId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case canonicalSetId
    }
}

/// Response wrapper for topics API
struct TopicsResponse: Codable {
    let success: Bool
    let topics: [OnboardingTopic]
}
