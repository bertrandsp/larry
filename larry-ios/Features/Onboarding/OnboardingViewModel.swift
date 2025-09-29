//
//  OnboardingViewModel.swift
//  larry-ios
//
//  Created by AI Assistant on 9/15/25.
//

import Foundation
import Combine

/// ViewModel managing the onboarding flow and user setup
@MainActor
class OnboardingViewModel: ObservableObject {
    private let onboardingAPI: OnboardingSubmitting
    
    // MARK: - Onboarding Steps
    
    enum OnboardingSourceOption: String, CaseIterable, Identifiable {
        case appStore
        case friend
        case social
        case search
        case other
        
        var id: String { rawValue }
        
        var title: String {
            switch self {
            case .appStore: return "App Store"
            case .friend: return "Friend Recommendation"
            case .social: return "Social Media"
            case .search: return "Online Search"
            case .other: return "Other"
            }
        }
        
        var iconName: String {
            switch self {
            case .appStore: return "app.badge"
            case .friend: return "person.2.fill"
            case .social: return "globe.americas.fill"
            case .search: return "magnifyingglass"
            case .other: return "ellipsis"
            }
        }
    }

    enum LearningLevelOption: String, CaseIterable, Identifiable {
        case scratch
        case beginner
        case intermediate
        case advanced
        case professional
        
        var id: String { rawValue }
        
        var title: String {
            switch self {
            case .scratch: return "Starting from Scratch"
            case .beginner: return "Beginner"
            case .intermediate: return "Intermediate"
            case .advanced: return "Advanced"
            case .professional: return "Professional Use"
            }
        }
        
        var subtitle: String {
            switch self {
            case .scratch: return "New to vocabulary, eager to begin."
            case .beginner: return "Know some words, but struggle with fluency."
            case .intermediate: return "Comfortable, but want to expand vocabulary."
            case .advanced: return "Strong vocabulary, aiming for nuance."
            case .professional: return "Need specialized vocabulary for work/academics."
            }
        }
        
        var iconName: String {
            switch self {
            case .scratch: return "sparkles"
            case .beginner: return "book"
            case .intermediate: return "graduationcap"
            case .advanced: return "lightbulb"
            case .professional: return "briefcase.fill"
            }
        }
    }


    enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case dailyGoal
        case weekPreview
        case source
        case skillLevel
        case widgetPrompt
        case motivation
        case topics
        case complete
        
        var title: String {
            switch self {
            case .welcome: return "Welcome"
            case .dailyGoal: return "Daily Goal"
            case .weekPreview: return "Your First Week"
            case .source: return "How You Found Us"
            case .skillLevel: return "Skill Level"
            case .widgetPrompt: return "Daily Word Widget"
            case .motivation: return "Motivation"
            case .topics: return "Topics"
            case .complete: return "Complete"
            }
        }
        
        var subtitle: String? {
            switch self {
            case .welcome:
                return nil
            case .dailyGoal:
                return "Set your daily learning target"
            case .weekPreview:
                return nil
            case .source:
                return "How did you hear about Larry?"
            case .skillLevel:
                return "Tell us your current familiarity"
            case .widgetPrompt:
                return "Add Larry to your home screen"
            case .motivation:
                return nil
            case .topics:
                return "Pick at least 3"
            case .complete:
                return nil
            }
        }
    }
    
    // MARK: - Published Properties
    
    @Published var currentStep: OnboardingStep = .welcome
    @Published var availableTopics: [OnboardingTopic] = []
    @Published var selectedTopics: Set<String> = []
    @Published var customTopicText: String = ""
    @Published private(set) var customTopicNames: [String: String] = [:]
    
    // First daily word state
    @Published var isPreparingFirstWord: Bool = false
    @Published var firstWordReady: Bool = false
    @Published var firstWordError: String?
    
    // User Profile Fields
    @Published var name: String = ""
    @Published var username: String = ""
    @Published var professionCurrent: String = ""
    @Published var professionTarget: String = ""
    @Published var goal: String = ""
    @Published var hobbies: [String] = []
    @Published var languages: [String] = []
    @Published var travelLocation: String = ""
    @Published var travelDate: Date? = nil
    
    // Preferences
    @Published var preferredDifficulty: Term.DifficultyLevel = .intermediate
    @Published var enableNotifications = true
    @Published var notificationTime = Date()
    @Published var dailyWordGoal: Int = 10
    @Published var onboardingSource: OnboardingSourceOption? = nil
    @Published var learningLevel: LearningLevelOption? = nil
    @Published var widgetOptIn: Bool? = nil
    @Published var isLoading = false
    @Published var showingError = false
    @Published var errorMessage = ""
    
    // MARK: - Computed Properties
    
    var progress: Double {
        let totalSteps = Double(OnboardingStep.allCases.count)
        return Double(currentStep.rawValue) / max(totalSteps - 1, 1)
    }
    
    var canGoBack: Bool {
        return currentStep != .welcome && currentStep != .complete
    }
    
    var canGoNext: Bool {
        switch currentStep {
        case .welcome:
            return true
        case .dailyGoal:
            return dailyWordGoal >= 1
        case .weekPreview:
            return true
        case .source:
            return onboardingSource != nil
        case .skillLevel:
            return learningLevel != nil
        case .widgetPrompt:
            return widgetOptIn != nil
        case .motivation:
            return true
        case .topics:
            return selectedTopics.count >= 3
        case .complete:
            return false
        }
    }
    
    var nextButtonTitle: String {
        switch currentStep {
        case .complete:
            return "Get Started"
        case .widgetPrompt:
            return widgetOptIn == true ? "Add Widget" : "Continue"
        case .dailyGoal:
            return "Commit to Goal"
        default:
            return "Continue"
        }
    }
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(onboardingAPI: OnboardingSubmitting = RemoteOnboardingAPI()) {
        self.onboardingAPI = onboardingAPI
        loadAvailableTopics()
        
        #if DEBUG
        print("📚 OnboardingViewModel initialized")
        #endif
        currentStep = .welcome
        Task { await recordStep(.welcome) }
    }
    
    // MARK: - Navigation Methods
    
    func goNext() async {
        guard currentStep != .complete else { return }
        await saveCurrentStepData()
        if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            currentStep = nextStep
            await recordStep(nextStep)
            if nextStep == .complete {
                await completeOnboarding()
            }
        }
    }
    
    func goBack() {
        guard canGoBack else { return }
        
        if let previousStep = OnboardingStep(rawValue: currentStep.rawValue - 1) {
            currentStep = previousStep
            Task { await recordStep(previousStep) }
        }
    }
    
    // MARK: - Data Persistence
    
    private func saveCurrentStepData() async {
        guard let user = AuthManager.shared.currentUser else {
            #if DEBUG
            print("❌ No current user to save data for")
            #endif
            return
        }
        do {
            try await submit(step: currentStep, userId: user.id)
        } catch {
            #if DEBUG
            print("❌ Failed to save data for step \(currentStep.title): \(error)")
            #endif
        }
    }

    private func submit(step: OnboardingStep, userId: String) async throws {
        switch step {
        case .welcome, .weekPreview, .motivation:
            break // informational screens
        case .dailyGoal:
            try await onboardingAPI.submitDailyGoal(userId: userId, goal: dailyWordGoal)
        case .source:
            if let source = onboardingSource {
                try await onboardingAPI.submitSource(userId: userId, source: source.rawValue)
            }
        case .skillLevel:
            if let level = learningLevel {
                try await onboardingAPI.submitSkillLevel(userId: userId, level: level.rawValue)
            }
        case .widgetPrompt:
            if let widget = widgetOptIn {
                try await onboardingAPI.submitWidgetPreference(userId: userId, enabled: widget)
            }
        case .topics:
            if !selectedTopics.isEmpty {
                let (stock, custom) = partitionSelectedTopics()
                try await onboardingAPI.submitTopics(userId: userId, topicIds: stock, customTopics: custom)
            }
        case .complete:
            break
        }
    }

    private func recordStep(_ step: OnboardingStep) async {
        guard let user = AuthManager.shared.currentUser,
              let key = onboardingStepKey(for: step) else { return }
        do {
            try await onboardingAPI.recordStep(userId: user.id, step: key)
        } catch {
            #if DEBUG
            print("⚠️ Failed to record onboarding step \(step.title): \(error)")
            #endif
        }
    }
    
    // MARK: - Topic Management
    
    func toggleTopic(_ topicId: String) {
        if selectedTopics.contains(topicId) {
            selectedTopics.remove(topicId)
        } else {
            selectedTopics.insert(topicId)
        }
    }
    
    func addCustomTopic() {
        let trimmedText = customTopicText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        // Check if topic already exists
        let existingTopic = availableTopics.first { $0.name.lowercased() == trimmedText.lowercased() }
        guard existingTopic == nil else {
            customTopicText = ""
            return
        }
        
        // Create a new custom topic
        let customTopic = OnboardingTopic(
            id: "custom-\(UUID().uuidString)",
            name: trimmedText,
            canonicalSetId: nil
        )
        
        // Add to available topics and track custom label
        availableTopics.append(customTopic)
        customTopicNames[customTopic.id] = trimmedText
        
        // Clear the input
        customTopicText = ""
        
        #if DEBUG
        print("✅ Added custom topic: \(trimmedText)")
        #endif
    }

    private func partitionSelectedTopics() -> ([String], [String]) {
        var stock: [String] = []
        var custom: [String] = []
        for topicId in selectedTopics {
            if let name = customTopicNames[topicId] {
                custom.append(name)
            } else {
                stock.append(topicId)
            }
        }
        return (stock, custom)
    }

    private func onboardingStepKey(for step: OnboardingStep) -> OnboardingStepKey? {
        switch step {
        case .welcome:
            return .welcome
        case .dailyGoal:
            return .dailyGoal
        case .weekPreview:
            return .weekPreview
        case .source:
            return .source
        case .skillLevel:
            return .skillLevel
        case .widgetPrompt:
            return .widget
        case .motivation:
            return .motivation
        case .topics:
            return .topics
        case .complete:
            return nil
        }
    }
    
    // MARK: - Data Loading
    
    private func loadAvailableTopics() {
        Task {
            do {
                availableTopics = try await onboardingAPI.fetchTopics()
            } catch {
                // Fallback to empty array since we need real API data
                availableTopics = []
                #if DEBUG
                print("⚠️ Failed to load topics from API, falling back to preview: \(error)")
                #endif
            }
        }
    }
    
    // MARK: - Onboarding Completion
    
    private func completeOnboarding() async {
        isLoading = true
        
        do {
            // Create travel plan if location is provided
            var travelPlan: TravelPlan? = nil
            if !travelLocation.isEmpty {
                travelPlan = TravelPlan(
                    location: travelLocation,
                    startDate: travelDate
                )
            }
            
            // Create onboarding completion request
            let request = try APIRequest(
                method: .POST,
                path: "/onboarding/complete",
                body: OnboardingCompletionRequest(
                    name: name,
                    username: username.isEmpty ? nil : username,
                    professionCurrent: professionCurrent.isEmpty ? nil : professionCurrent,
                    professionTarget: professionTarget.isEmpty ? nil : professionTarget,
                    goal: goal,
                    hobbies: hobbies,
                    languages: languages,
                    travelPlan: travelPlan,
                    selectedTopics: Array(selectedTopics),
                    preferredDifficulty: preferredDifficulty,
                    enableNotifications: enableNotifications,
                    notificationTime: enableNotifications ? notificationTime : nil,
                    dailyWordGoal: Int(dailyWordGoal)
                )
            )
            
            let response: OnboardingCompletionResponse = try await APIService.shared.send(
                request,
                responseType: OnboardingCompletionResponse.self
            )
            
            // Update auth manager with completed onboarding
            if AuthManager.shared.currentUser != nil {
                // This would require making User mutable or refreshing from API
                // For now, we'll refresh the user profile
                await refreshUserProfile()
            }
            
            #if DEBUG
            print("✅ Onboarding completed successfully")
            #endif
            
            // After successful onboarding, trigger first daily word generation
            if let user = response.user {
                await prepareFirstDailyWord(userId: user.id)
            }
            
        } catch {
            #if DEBUG
            print("❌ Failed to complete onboarding: \(error)")
            #endif
            
            errorMessage = error.localizedDescription
            showingError = true
        }
        
        isLoading = false
    }
    
    private func refreshUserProfile() async {
        // Update the current user to mark onboarding as completed
        if let user = AuthManager.shared.currentUser {
            // Create a new user object with onboarding completed
            let updatedUser = User(
                id: user.id,
                email: user.email,
                name: name.isEmpty ? user.name : name,
                profileImageURL: user.profileImageURL,
                createdAt: user.createdAt,
                updatedAt: Date(),
                onboardingCompleted: true,
                streakCount: user.streakCount,
                totalWordsLearned: user.totalWordsLearned,
                subscription: user.subscription
            )
            
            // Update the auth manager with the completed user
            AuthManager.shared.currentUser = updatedUser
            
            #if DEBUG
            print("✅ User profile updated with onboarding completed")
            #endif
        }
    }
    
    // MARK: - First Daily Word Preparation
    
    private func prepareFirstDailyWord(userId: String) async {
        isPreparingFirstWord = true
        firstWordError = nil
        
        #if DEBUG
        print("🎯 Preparing first daily word for user: \(userId)")
        #endif
        
        do {
            let response = try await APIService.shared.getFirstDailyWord(userId: userId)
            
            if response.generating == true {
                // Word is still being generated, show loading state
                #if DEBUG
                print("🚀 First word is being generated, estimated time: \(response.estimatedTime ?? "unknown")")
                #endif
                
                // Wait and retry
                if let retryAfter = response.retryAfter {
                    try await Task.sleep(nanoseconds: UInt64(retryAfter) * 1_000_000_000)
                    await prepareFirstDailyWord(userId: userId) // Retry
                }
            } else if response.success && response.firstVocabGenerated == true {
                // First word is ready!
                firstWordReady = true
                
                #if DEBUG
                print("✅ First daily word is ready!")
                #endif
            } else if let redirect = response.redirect {
                // User already has vocab generated, redirect to regular flow
                firstWordReady = true
                
                #if DEBUG
                print("ℹ️ User already has vocab, redirecting to: \(redirect)")
                #endif
            }
            
        } catch {
            #if DEBUG
            print("❌ Failed to prepare first daily word: \(error)")
            #endif
            
            firstWordError = error.localizedDescription
        }
        
        isPreparingFirstWord = false
    }
}

// MARK: - Request/Response Models

private struct TravelPlan: Codable {
    let location: String
    let startDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case location
        case startDate = "start_date"
    }
}

private struct OnboardingCompletionRequest: Codable {
    let name: String
    let username: String?
    let professionCurrent: String?
    let professionTarget: String?
    let goal: String
    let hobbies: [String]
    let languages: [String]
    let travelPlan: TravelPlan?
    let selectedTopics: [String]
    let preferredDifficulty: Term.DifficultyLevel
    let enableNotifications: Bool
    let notificationTime: Date?
    let dailyWordGoal: Int
    
    enum CodingKeys: String, CodingKey {
        case name
        case username
        case professionCurrent = "profession_current"
        case professionTarget = "profession_target"
        case goal
        case hobbies
        case languages
        case travelPlan = "travel_plan"
        case selectedTopics = "selected_topics"
        case preferredDifficulty = "preferred_difficulty"
        case enableNotifications = "enable_notifications"
        case notificationTime = "notification_time"
        case dailyWordGoal = "daily_word_goal"
    }
}

private struct OnboardingCompletionResponse: Codable {
    let success: Bool
    let user: User?
}

private struct ProfileUpdateResponse: Codable {
    let success: Bool
    let user: UserProfileData
}

private struct ProfileUpdateRequest: Codable {
    let userId: String
    let name: String?
    let username: String?
    let professionCurrent: String?
    let professionTarget: String?
    let goal: String?
    let hobbies: [String]?
    let languages: [String]?
    let travelLocation: String?
    let travelDate: String?
    let preferredDifficulty: String?
    let enableNotifications: Bool?
    let notificationTime: String?
    let dailyWordGoal: Int?
}

private struct UserProfileData: Codable {
    let id: String
    let email: String
    let name: String?
    let username: String?
    let professionCurrent: String?
    let professionTarget: String?
    let goal: String?
    let hobbies: [String]
    let languages: [String]
    let travelLocation: String?
    let travelDate: String?
    let preferredDifficulty: String
    let enableNotifications: Bool
    let notificationTime: String?
    let dailyWordGoal: Int
    let onboardingCompleted: Bool
    let createdAt: String
    let updatedAt: String
}

