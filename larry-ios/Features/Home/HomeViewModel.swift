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
    @Published var firstDailyWord: ViewState<EnhancedFirstDailyWordResponse> = .idle
    @Published var isRefreshing = false
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private var refreshTimer: Timer?
    private var lastRefreshTime: Date = Date.distantPast
    
    // MARK: - Configuration
    
    private let refreshInterval: TimeInterval = 30.0 // Refresh every 30 seconds
    private let maxRefreshInterval: TimeInterval = 300.0 // Maximum 5 minutes between refreshes
    
    // MARK: - Initialization
    
    init() {
        #if DEBUG
        print("🏠 HomeViewModel initialized")
        #endif
        startPeriodicRefresh()
    }
    
    deinit {
        stopPeriodicRefresh()
    }
    
    // MARK: - Public Methods
    
    func loadInitialData() async {
        await loadDailyWords()
        await loadFirstDailyWord()
    }
    
    func refreshData() async {
        isRefreshing = true
        await loadDailyWords()
        await loadFirstDailyWord()
        isRefreshing = false
        lastRefreshTime = Date()
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
            lastRefreshTime = Date()
            
            #if DEBUG
            print("✅ Daily words loaded: \(response.words.count) words at \(Date())")
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
    
    // MARK: - Periodic Refresh Management
    
    private func startPeriodicRefresh() {
        #if DEBUG
        print("🔄 Starting periodic refresh (every \(refreshInterval)s)")
        #endif
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.performPeriodicRefresh()
            }
        }
    }
    
    private func stopPeriodicRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
        
        #if DEBUG
        print("⏹️ Stopped periodic refresh")
        #endif
    }
    
    private func performPeriodicRefresh() async {
        // Don't refresh if we just refreshed recently
        let timeSinceLastRefresh = Date().timeIntervalSince(lastRefreshTime)
        if timeSinceLastRefresh < refreshInterval {
            #if DEBUG
            print("⏭️ Skipping refresh - too soon (last: \(Int(timeSinceLastRefresh))s ago)")
            #endif
            return
        }
        
        // Don't refresh if user is actively refreshing
        if isRefreshing {
            #if DEBUG
            print("⏭️ Skipping refresh - user is manually refreshing")
            #endif
            return
        }
        
        // Don't refresh if we're in error state (avoid spam)
        if case .error = dailyWords {
            #if DEBUG
            print("⏭️ Skipping refresh - in error state")
            #endif
            return
        }
        
        #if DEBUG
        print("🔄 Performing background refresh...")
        #endif
        
        // Perform silent refresh without showing loading state
        await loadDailyWords()
    }
    
    // MARK: - Smart Refresh (Context-Aware)
    
    func smartRefresh() async {
        // Check if we have recent data
        let timeSinceLastRefresh = Date().timeIntervalSince(lastRefreshTime)
        
        if timeSinceLastRefresh < 10.0 {
            #if DEBUG
            print("⏭️ Skipping smart refresh - data is fresh (\(Int(timeSinceLastRefresh))s old)")
            #endif
            return
        }
        
        #if DEBUG
        print("🧠 Performing smart refresh...")
        #endif
        
        await refreshData()
    }
    
    // MARK: - App Lifecycle Management
    
    func handleAppBecameActive() {
        #if DEBUG
        print("📱 App became active - checking for updates")
        #endif
        
        Task {
            await smartRefresh()
        }
    }
    
    func handleAppWillResignActive() {
        #if DEBUG
        print("📱 App will resign active - stopping periodic refresh")
        #endif
        
        // Stop periodic refresh when app goes to background to save battery
        stopPeriodicRefresh()
    }
    
    func handleAppDidEnterBackground() {
        #if DEBUG
        print("📱 App entered background")
        #endif
    }
    
    func handleAppWillEnterForeground() {
        #if DEBUG
        print("📱 App will enter foreground - restarting periodic refresh")
        #endif
        
        // Restart periodic refresh when app comes back to foreground
        startPeriodicRefresh()
        
        // Immediately check for updates
        Task {
            await smartRefresh()
        }
    }

// ... existing code ...