//
//  HomeViewModel.swift
//  larry-ios
//
//  Created by AI Assistant on 9/15/25.
//

import Foundation
import Combine

/// ViewModel for the home screen, managing daily words and user data
@MainActor
class HomeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var dailyWords: ViewState<DailyWordsResponse> = .idle
    @Published var isRefreshing = false
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        #if DEBUG
        print("🏠 HomeViewModel initialized")
        #endif
    }
    
    // MARK: - Public Methods
    
    func loadInitialData() async {
        await loadDailyWords()
    }
    
    func refreshData() async {
        isRefreshing = true
        await loadDailyWords()
        isRefreshing = false
    }
    
    func loadDailyWords() async {
        dailyWords.setLoading()
        
        do {
            let request = APIRequest(
                method: .GET,
                path: "/daily"
            )
            
            let response: DailyWordsResponse = try await APIService.shared.send(
                request,
                responseType: DailyWordsResponse.self
            )
            
            dailyWords.setSuccess(response)
            
            #if DEBUG
            print("✅ Daily words loaded: \(response.words.count) words")
            #endif
            
        } catch {
            #if DEBUG
            print("❌ Failed to load daily words: \(error)")
            #endif
            
            // Use mock data in debug mode if API fails
            #if DEBUG
            if error is NetworkError {
                dailyWords.setSuccess(DailyWordsResponse.previewData)
                print("🔄 Using mock data for development")
                return
            }
            #endif
            
            dailyWords.setError(error)
        }
    }
    
    // MARK: - Word Actions
    
    func markAsFavorite(_ dailyWordId: String) async {
        do {
            let request = try APIRequest(
                method: .POST,
                path: "/actions/favorite",
                body: WordActionRequest(dailyWordId: dailyWordId)
            )
            
            try await APIService.shared.send(request)
            
            // Update local state
            updateWordLocally(dailyWordId) { interaction in
                var updated = interaction ?? createDefaultInteraction(for: dailyWordId)
                updated.markedAsFavorite = true
                return updated
            }
            
            #if DEBUG
            print("✅ Word marked as favorite")
            #endif
            
        } catch {
            #if DEBUG
            print("❌ Failed to mark word as favorite: \(error)")
            #endif
        }
    }
    
    func markForRelearning(_ dailyWordId: String) async {
        do {
            let request = try APIRequest(
                method: .POST,
                path: "/actions/learn-again",
                body: WordActionRequest(dailyWordId: dailyWordId)
            )
            
            try await APIService.shared.send(request)
            
            // Update local state
            updateWordLocally(dailyWordId) { interaction in
                var updated = interaction ?? createDefaultInteraction(for: dailyWordId)
                updated.markedForRelearning = true
                return updated
            }
            
            #if DEBUG
            print("✅ Word marked for re-learning")
            #endif
            
        } catch {
            #if DEBUG
            print("❌ Failed to mark word for re-learning: \(error)")
            #endif
        }
    }
    
    func markAsMastered(_ dailyWordId: String) async {
        do {
            let request = try APIRequest(
                method: .POST,
                path: "/actions/mastered",
                body: WordActionRequest(dailyWordId: dailyWordId)
            )
            
            try await APIService.shared.send(request)
            
            // Update local state
            updateWordLocally(dailyWordId) { interaction in
                var updated = interaction ?? createDefaultInteraction(for: dailyWordId)
                updated.markedAsMastered = true
                return updated
            }
            
            #if DEBUG
            print("✅ Word marked as mastered")
            #endif
            
        } catch {
            #if DEBUG
            print("❌ Failed to mark word as mastered: \(error)")
            #endif
        }
    }
    
    // MARK: - Private Helpers
    
    private func updateWordLocally(
        _ dailyWordId: String,
        transform: (DailyWordInteraction?) -> DailyWordInteraction
    ) {
        // Note: Since our models are immutable structs, we'll refresh the data after API calls
        // In a production app, you might want to use a more sophisticated state management approach
        // For now, we'll just refresh the data to get the updated state from the server
        Task {
            await loadDailyWords()
        }
    }
    
    private func createDefaultInteraction(for dailyWordId: String) -> DailyWordInteraction {
        return DailyWordInteraction(
            dailyWordId: dailyWordId,
            userId: AuthManager.shared.currentUser?.id ?? "",
            viewedAt: Date(),
            completedAt: nil,
            markedAsFavorite: false,
            markedForRelearning: false,
            markedAsMastered: false,
            timeSpentSeconds: nil,
            aiChatUsed: false,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

// MARK: - Request Models

private struct WordActionRequest: Codable {
    let dailyWordId: String
    
    enum CodingKeys: String, CodingKey {
        case dailyWordId = "daily_word_id"
    }
}
