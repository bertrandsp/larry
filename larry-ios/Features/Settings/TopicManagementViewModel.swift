//
//  TopicManagementViewModel.swift
//  larry-ios
//
//  Created by AI Assistant on 10/2/25.
//

import Foundation
import Combine

/// ViewModel for managing user topics and interests
@MainActor
class TopicManagementViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var userTopics: [UserTopic] = []
    @Published var availableTopics: [AvailableTopic] = []
    @Published var state: TopicManagementState = .idle
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let apiService: APIService
    private var cancellables = Set<AnyCancellable>()
    private let userId: String // In a real app, this would come from AuthManager
    
    // MARK: - Initialization
    
    init(apiService: APIService = APIService.shared, userId: String = "default-user") {
        self.apiService = apiService
        self.userId = userId
    }
    
    // MARK: - Public Methods
    
    /// Load both user topics and available topics
    func loadTopics() async {
        state = .loading
        errorMessage = nil
        
        do {
            // Load user topics and available topics concurrently
            async let userTopicsTask = loadUserTopics()
            async let availableTopicsTask = loadAvailableTopics()
            
            try await userTopicsTask
            try await availableTopicsTask
            
            state = .loaded
        } catch {
            await handleError(error)
        }
    }
    
    /// Load only user topics
    func loadUserTopics() async throws {
        let response = try await apiService.getUserTopics(userId: userId)
        userTopics = response.topics
    }
    
    /// Load only available topics (excluding user's current topics)
    func loadAvailableTopics() async throws {
        let response = try await apiService.getAvailableTopics(excludeUserId: userId)
        availableTopics = response.topics
    }
    
    /// Add a topic to the user's interests
    func addTopic(_ topic: AvailableTopic, weight: Int = 50) async {
        state = .loading
        errorMessage = nil
        
        do {
            let response = try await apiService.addTopicToUser(
                userId: userId,
                topicId: topic.id,
                weight: weight
            )
            
            // Convert the added topic to UserTopic format
            let newUserTopic = UserTopic(
                id: response.userTopic.id,
                topicId: response.userTopic.topicId,
                name: response.userTopic.topic.name,
                weight: response.userTopic.weight,
                enabled: response.userTopic.enabled,
                termCount: response.userTopic.topic.termCount,
                category: response.userTopic.topic.category,
                createdAt: response.userTopic.createdAt,
                updatedAt: response.userTopic.updatedAt
            )
            
            // Update local state
            userTopics.append(newUserTopic)
            availableTopics.removeAll { $0.id == topic.id }
            
            state = .loaded
        } catch {
            await handleError(error)
        }
    }
    
    /// Update the weight of a user's topic
    func updateTopicWeight(_ userTopic: UserTopic, newWeight: Int) async {
        state = .loading
        errorMessage = nil
        
        do {
            let response = try await apiService.updateTopicWeight(
                userTopicId: userTopic.id,
                weight: newWeight
            )
            
            // Update local state
            if let index = userTopics.firstIndex(where: { $0.id == userTopic.id }) {
                userTopics[index] = response.userTopic
            }
            
            state = .loaded
        } catch {
            await handleError(error)
        }
    }
    
    /// Toggle a topic's enabled/disabled state
    func toggleTopic(_ userTopic: UserTopic) async {
        state = .loading
        errorMessage = nil
        
        do {
            let response = try await apiService.toggleTopicEnabled(userTopicId: userTopic.id)
            
            // Update local state
            if let index = userTopics.firstIndex(where: { $0.id == userTopic.id }) {
                userTopics[index] = response.userTopic
            }
            
            state = .loaded
        } catch {
            await handleError(error)
        }
    }
    
    /// Remove a topic from the user's interests
    func removeTopic(_ userTopic: UserTopic) async {
        state = .loading
        errorMessage = nil
        
        do {
            try await apiService.removeTopicFromUser(userTopicId: userTopic.id)
            
            // Update local state
            userTopics.removeAll { $0.id == userTopic.id }
            
            // Add the topic back to available topics if we have the data
            // In a real implementation, you might want to reload available topics
            // or keep a reference to the original AvailableTopic
            
            state = .loaded
        } catch {
            await handleError(error)
        }
    }
    
    /// Refresh all data
    func refresh() async {
        await loadTopics()
    }
    
    // MARK: - Computed Properties
    
    /// Total weight of all enabled topics
    var totalWeight: Int {
        userTopics.filter { $0.enabled }.reduce(0) { $0 + $1.weight }
    }
    
    /// Whether the total weight equals 100%
    var isWeightBalanced: Bool {
        totalWeight == 100
    }
    
    /// Number of enabled topics
    var enabledTopicsCount: Int {
        userTopics.filter { $0.enabled }.count
    }
    
    /// Number of disabled topics
    var disabledTopicsCount: Int {
        userTopics.filter { !$0.enabled }.count
    }
    
    /// Topics sorted by weight (descending)
    var topicsByWeight: [UserTopic] {
        userTopics.sorted { $0.weight > $1.weight }
    }
    
    /// Available topics sorted by popularity
    var popularAvailableTopics: [AvailableTopic] {
        availableTopics.sorted { $0.isPopular && !$1.isPopular }
    }
    
    // MARK: - Helper Methods
    
    /// Validate that a weight value is acceptable
    func isValidWeight(_ weight: Int) -> Bool {
        return weight >= 0 && weight <= 100
    }
    
    /// Calculate suggested weight for a new topic
    func suggestedWeightForNewTopic() -> Int {
        let currentTotal = totalWeight
        let enabledCount = enabledTopicsCount
        
        if enabledCount == 0 {
            return 100 // First topic gets 100%
        }
        
        if currentTotal < 100 {
            return min(100 - currentTotal, 25) // Use remaining weight, max 25%
        }
        
        return 20 // Default suggestion
    }
    
    /// Auto-balance weights to total 100%
    func autoBalanceWeights() async {
        let enabledTopics = userTopics.filter { $0.enabled }
        guard !enabledTopics.isEmpty else { return }
        
        let baseWeight = 100 / enabledTopics.count
        let remainder = 100 % enabledTopics.count
        
        state = .loading
        errorMessage = nil
        
        do {
            // Update weights for all enabled topics
            for (index, topic) in enabledTopics.enumerated() {
                let newWeight = baseWeight + (index < remainder ? 1 : 0)
                
                if topic.weight != newWeight {
                    let response = try await apiService.updateTopicWeight(
                        userTopicId: topic.id,
                        weight: newWeight
                    )
                    
                    // Update local state
                    if let localIndex = userTopics.firstIndex(where: { $0.id == topic.id }) {
                        userTopics[localIndex] = response.userTopic
                    }
                }
            }
            
            state = .loaded
        } catch {
            await handleError(error)
        }
    }
    
    // MARK: - Private Methods
    
    private func handleError(_ error: Error) async {
        state = .error(error.localizedDescription)
        errorMessage = error.localizedDescription
        
        #if DEBUG
        print("❌ TopicManagementViewModel Error: \(error)")
        #endif
    }
}

// MARK: - Preview Support

extension TopicManagementViewModel {
    /// Create a view model with mock data for previews
    static func preview() -> TopicManagementViewModel {
        let viewModel = TopicManagementViewModel()
        viewModel.userTopics = UserTopic.previewDataList
        viewModel.availableTopics = AvailableTopic.previewDataList
        viewModel.state = .loaded
        return viewModel
    }
    
    /// Create a view model with loading state for previews
    static func previewLoading() -> TopicManagementViewModel {
        let viewModel = TopicManagementViewModel()
        viewModel.state = .loading
        return viewModel
    }
    
    /// Create a view model with error state for previews
    static func previewError() -> TopicManagementViewModel {
        let viewModel = TopicManagementViewModel()
        viewModel.state = .error("Failed to load topics. Please check your connection and try again.")
        viewModel.errorMessage = "Failed to load topics. Please check your connection and try again."
        return viewModel
    }
}
