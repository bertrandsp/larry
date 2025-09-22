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
    
    // MARK: - Onboarding Steps
    
    enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case identity = 1
        case interests = 2
        case preferences = 3
        case complete = 4
        
        var title: String {
            switch self {
            case .welcome: return "Welcome"
            case .identity: return "About You"
            case .interests: return "Interests"
            case .preferences: return "Preferences"
            case .complete: return "Complete"
            }
        }
    }
    
    // MARK: - Published Properties
    
    @Published var currentStep: OnboardingStep = .welcome
    @Published var availableTopics: [Topic] = []
    @Published var selectedTopics: Set<String> = []
    @Published var customTopicText: String = ""
    
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
    @Published var dailyWordGoal: Double = 2
    @Published var isLoading = false
    @Published var showingError = false
    @Published var errorMessage = ""
    
    // MARK: - Computed Properties
    
    var progress: Double {
        return Double(currentStep.rawValue) / Double(OnboardingStep.allCases.count - 1)
    }
    
    var canGoBack: Bool {
        return currentStep != .welcome && currentStep != .complete
    }
    
    var canGoNext: Bool {
        switch currentStep {
        case .welcome:
            return true
        case .identity:
            return !name.isEmpty && !goal.isEmpty
        case .interests:
            return selectedTopics.count >= 3
        case .preferences:
            return true
        case .complete:
            return false
        }
    }
    
    var nextButtonTitle: String {
        switch currentStep {
        case .welcome, .identity, .interests, .preferences:
            return "Continue"
        case .complete:
            return "Get Started"
        }
    }
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        loadAvailableTopics()
        
        #if DEBUG
        print("📚 OnboardingViewModel initialized")
        #endif
    }
    
    // MARK: - Navigation Methods
    
    func goNext() async {
        switch currentStep {
        case .welcome:
            currentStep = .identity
            
        case .identity:
            if canGoNext {
                await saveCurrentStepData()
                currentStep = .interests
            }
            
        case .interests:
            if canGoNext {
                await saveCurrentStepData()
                currentStep = .preferences
            }
            
        case .preferences:
            await saveCurrentStepData()
            currentStep = .complete
            await completeOnboarding()
            
        case .complete:
            // This shouldn't be reachable
            break
        }
    }
    
    func goBack() {
        guard canGoBack else { return }
        
        switch currentStep {
        case .identity:
            currentStep = .welcome
        case .interests:
            currentStep = .identity
        case .preferences:
            currentStep = .interests
        case .complete:
            currentStep = .preferences
        case .welcome:
            break
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
            var profileData: [String: Any] = [:]
            
            switch currentStep {
            case .identity:
                profileData = [
                    "name": name,
                    "username": username,
                    "professionCurrent": professionCurrent,
                    "professionTarget": professionTarget,
                    "goal": goal,
                    "hobbies": hobbies,
                    "languages": languages,
                    "travelLocation": travelLocation,
                    "travelDate": travelDate?.ISO8601Format() as Any
                ]
                
            case .interests:
                // Topics are saved separately in completeOnboarding
                break
                
            case .preferences:
                profileData = [
                    "preferredDifficulty": preferredDifficulty.rawValue,
                    "enableNotifications": enableNotifications,
                    "notificationTime": enableNotifications ? notificationTime : NSNull(),
                    "dailyWordGoal": Int(dailyWordGoal)
                ]
                
            default:
                break
            }
            
            // Only save if there's data to save
            if !profileData.isEmpty {
                let requestBody = ProfileUpdateRequest(
                    userId: user.id,
                    name: profileData["name"] as? String,
                    username: profileData["username"] as? String,
                    professionCurrent: profileData["professionCurrent"] as? String,
                    professionTarget: profileData["professionTarget"] as? String,
                    goal: profileData["goal"] as? String,
                    hobbies: profileData["hobbies"] as? [String],
                    languages: profileData["languages"] as? [String],
                    travelLocation: profileData["travelLocation"] as? String,
                    travelDate: profileData["travelDate"] as? String,
                    preferredDifficulty: profileData["preferredDifficulty"] as? String,
                    enableNotifications: profileData["enableNotifications"] as? Bool,
                    notificationTime: profileData["notificationTime"] as? String,
                    dailyWordGoal: profileData["dailyWordGoal"] as? Int
                )
                
                let request = try APIRequest(
                    method: .PUT,
                    path: "/user/profile",
                    body: requestBody
                )
                
                let _: ProfileUpdateResponse = try await APIService.shared.send(
                    request,
                    responseType: ProfileUpdateResponse.self
                )
                
                #if DEBUG
                print("✅ Saved \(currentStep.title) step data for user: \(user.id)")
                #endif
            }
            
        } catch {
            #if DEBUG
            print("❌ Failed to save \(currentStep.title) step data: \(error)")
            #endif
            // Don't block navigation on save failure
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
        let customTopic = Topic(
            id: "custom-\(UUID().uuidString)",
            name: trimmedText,
            description: "Custom topic: \(trimmedText)",
            category: .other,
            iconName: "plus.circle",
            colorHex: "#007AFF",
            isActive: true,
            termCount: 0,
            createdAt: Date(),
            updatedAt: Date(),
            userTopicWeight: nil
        )
        
        // Add to available topics
        availableTopics.append(customTopic)
        
        // Clear the input
        customTopicText = ""
        
        #if DEBUG
        print("✅ Added custom topic: \(trimmedText)")
        #endif
    }
    
    // MARK: - Data Loading
    
    private func loadAvailableTopics() {
        // For now, use mock data
        // In production, this would load from the API
        availableTopics = Topic.previewDataList
        
        #if DEBUG
        print("📖 Loaded \(availableTopics.count) available topics")
        #endif
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

