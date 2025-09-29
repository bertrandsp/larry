import Foundation

protocol OnboardingSubmitting {
    func fetchTopics() async throws -> [OnboardingTopic]
    func recordStep(userId: String, step: OnboardingStepKey) async throws
    func submitDailyGoal(userId: String, goal: Int) async throws
    func submitSource(userId: String, source: String) async throws
    func submitSkillLevel(userId: String, level: String) async throws
    func submitWidgetPreference(userId: String, enabled: Bool) async throws
    func submitLearningPath(userId: String, path: String) async throws
    func submitTopics(userId: String, topicIds: [String], customTopics: [String]) async throws
}

enum OnboardingStepKey: String {
    case welcome
    case dailyGoal
    case weekPreview
    case source
    case skillLevel
    case widget
    case motivation
    case learningPath
    case topics
}

struct OnboardingAPIError: Error, LocalizedError {
    enum Reason {
        case unsupportedStep
    }
    let reason: Reason
    var errorDescription: String? {
        switch reason {
        case .unsupportedStep:
            return "Attempted to record an unsupported onboarding step."
        }
    }
}

final class RemoteOnboardingAPI: OnboardingSubmitting {
    private let apiService: APIService
    
    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }
    
    func fetchTopics() async throws -> [OnboardingTopic] {
        try await apiService.getOnboardingTopics()
    }
    
    func recordStep(userId: String, step: OnboardingStepKey) async throws {
        let path: String
        switch step {
        case .welcome:
            path = "/onboarding/welcome"
        case .dailyGoal:
            path = "/onboarding/daily-goal"
        case .weekPreview:
            path = "/onboarding/week-preview"
        case .source:
            path = "/onboarding/source"
        case .skillLevel:
            path = "/onboarding/skill-level"
        case .widget:
            path = "/onboarding/widget-preference"
        case .motivation:
            path = "/onboarding/motivation"
        case .learningPath:
            path = "/onboarding/learning-path"
        case .topics:
            path = "/onboarding/topics"
        }
        try await apiService.postOnboardingStep(RecordStepRequest(userId: userId), path: path)
    }
    
    func submitDailyGoal(userId: String, goal: Int) async throws {
        try await apiService.postOnboardingStep(
            DailyGoalRequest(goal: goal),
            path: "/onboarding/daily-goal"
        )
    }
    
    func submitSource(userId: String, source: String) async throws {
        try await apiService.postOnboardingStep(
            SourceRequest(source: source),
            path: "/onboarding/source"
        )
    }
    
    func submitSkillLevel(userId: String, level: String) async throws {
        try await apiService.postOnboardingStep(
            SkillLevelRequest(level: level),
            path: "/onboarding/skill-level"
        )
    }
    
    func submitWidgetPreference(userId: String, enabled: Bool) async throws {
        try await apiService.postOnboardingStep(
            WidgetPreferenceRequest(enabled: enabled),
            path: "/onboarding/widget-preference"
        )
    }
    
    func submitLearningPath(userId: String, path: String) async throws {
        try await apiService.postOnboardingStep(
            LearningPathRequest(path: path),
            path: "/onboarding/learning-path"
        )
    }
    
    func submitTopics(userId: String, topicIds: [String], customTopics: [String]) async throws {
        try await apiService.postOnboardingStep(
            TopicSelectionRequest(topicIds: topicIds, customTopics: customTopics),
            path: "/onboarding/topics"
        )
    }
}

// MARK: - Request payloads

private struct RecordStepRequest: Codable {
    let userId: String
}

private struct DailyGoalRequest: Codable {
    let goal: Int
}

private struct SourceRequest: Codable {
    let source: String
}

private struct SkillLevelRequest: Codable {
    let level: String
}

private struct WidgetPreferenceRequest: Codable {
    let enabled: Bool
}

private struct LearningPathRequest: Codable {
    let path: String
}

private struct TopicSelectionRequest: Codable {
    let topicIds: [String]
    let customTopics: [String]
}
