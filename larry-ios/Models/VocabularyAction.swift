//
//  VocabularyAction.swift
//  larry-ios
//
//  Created by AI Assistant on 10/1/25.
//

import Foundation

/// Represents user actions on vocabulary terms
enum VocabularyAction: String, CaseIterable, Codable {
    case favorite = "favorite"
    case unfavorite = "unfavorite"
    case markRelevant = "mark_relevant"
    case markUnrelated = "mark_unrelated"
    case learnAgain = "learn_again"
    case mastered = "mastered"
    case viewed = "viewed"
    case completed = "completed"
    case skipped = "skipped"
    
    var displayName: String {
        switch self {
        case .favorite:
            return "Add to Favorites"
        case .unfavorite:
            return "Remove from Favorites"
        case .markRelevant:
            return "Mark as Relevant"
        case .markUnrelated:
            return "Mark as Unrelated"
        case .learnAgain:
            return "Learn Again"
        case .mastered:
            return "Mark as Mastered"
        case .viewed:
            return "Viewed"
        case .completed:
            return "Completed"
        case .skipped:
            return "Skipped"
        }
    }
    
    var icon: String {
        switch self {
        case .favorite:
            return "heart.fill"
        case .unfavorite:
            return "heart"
        case .markRelevant:
            return "checkmark.circle.fill"
        case .markUnrelated:
            return "xmark.circle.fill"
        case .learnAgain:
            return "arrow.clockwise"
        case .mastered:
            return "star.fill"
        case .viewed:
            return "eye.fill"
        case .completed:
            return "checkmark.circle"
        case .skipped:
            return "forward.fill"
        }
    }
    
    var color: String {
        switch self {
        case .favorite, .markRelevant, .mastered:
            return "green"
        case .unfavorite, .markUnrelated, .skipped:
            return "red"
        case .learnAgain:
            return "blue"
        case .viewed, .completed:
            return "orange"
        }
    }
}
