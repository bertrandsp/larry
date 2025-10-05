//
//  EnhancedHomeView.swift
//  larry-ios
//
//  Created by AI Assistant on 9/15/25.
//

import SwiftUI

/// Enhanced home screen with automatic refresh and real-time updates
struct EnhancedHomeView: View {
    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Header with user info and streak
                    headerSection
                    
                    // Daily words section with real-time updates
                    enhancedDailyWordsSection
                    
                    // Quick actions
                    quickActionsSection
                    
                    // Recent activity
                    recentActivitySection
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .navigationTitle("Larry")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await authManager.logout()
                        }
                    } label: {
                        Image(systemName: "person.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    refreshButton
                }
            }
            .refreshable {
                await viewModel.refreshData()
            }
        }
        .task {
            await viewModel.loadInitialData()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            viewModel.handleAppBecameActive()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            viewModel.handleAppWillResignActive()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            viewModel.handleAppDidEnterBackground()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            viewModel.handleAppWillEnterForeground()
        }
    }
    
    // MARK: - View Components
    
    private var refreshButton: some View {
        Button(action: {
            Task {
                await viewModel.refreshData()
            }
        }) {
            Image(systemName: viewModel.isRefreshing ? "arrow.clockwise" : "arrow.clockwise")
                .rotationEffect(.degrees(viewModel.isRefreshing ? 360 : 0))
                .animation(
                    viewModel.isRefreshing ? 
                    Animation.linear(duration: 1).repeatForever(autoreverses: false) : 
                    .default, 
                    value: viewModel.isRefreshing
                )
        }
        .disabled(viewModel.isRefreshing)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back!")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let user = authManager.currentUser {
                        Text(user.name ?? "Larry User")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Streak indicator
                VStack(alignment: .trailing, spacing: 4) {
                    Text("7")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Text("day streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Progress bar
            ProgressView(value: 0.6)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(y: 2)
            
            HStack {
                Text("3 of 5 words today")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("60%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 4)
    }
    
    private var enhancedDailyWordsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Words")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Real-time indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                        .scaleEffect(1.0)
                        .animation(
                            Animation.easeInOut(duration: 2).repeatForever(autoreverses: true),
                            value: UUID()
                        )
                    
                    Text("Live")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let remainingCount = viewModel.dailyWords.data?.remainingToday {
                    Text("\(remainingCount) remaining")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Enhanced first daily word section
            firstDailyWordSection
            
            // Regular daily words section with real-time updates
            switch viewModel.dailyWords {
            case .loading:
                loadingView
                
            case .success(let response):
                if response.words.isEmpty {
                    emptyWordsView
                } else {
                    wordsListView(response: response)
                }
                
            case .error(let error):
                errorView(error: error)
                
            case .idle:
                EmptyView()
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView("Loading your words...")
                .frame(maxWidth: .infinity)
            
            Text("Checking for new vocabulary...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 32)
    }
    
    private func wordsListView(response: DailyWordsResponse) -> some View {
        LazyVStack(spacing: 12) {
            ForEach(response.words) { word in
                EnhancedDailyWordCard(dailyWord: word)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: response.words.count)
    }
    
    private var emptyWordsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No Words Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("New vocabulary words will appear here as they're generated.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Check for Updates") {
                Task {
                    await viewModel.refreshData()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 32)
    }
    
    private func errorView(error: Error) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Failed to Load Words")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 12) {
                Button("Retry") {
                    Task {
                        await viewModel.refreshData()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Check Connection") {
                    Task {
                        await viewModel.loadDailyWords()
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 32)
    }
    
    private var firstDailyWordSection: some View {
        Group {
            switch viewModel.firstDailyWord {
            case .loading:
                VStack {
                    ProgressView("Generating your first word...")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    
                    Text("This may take 30-60 seconds")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
            case .success(let response):
                if let firstWord = response.dailyWord {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Your First Word")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text("New!")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                        
                        EnhancedDailyWordCard(dailyWord: firstWord.toDailyWord())
                    }
                }
                
            case .error(let error):
                VStack {
                    Text("Failed to generate first word")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Try Again") {
                        Task {
                            await viewModel.loadFirstDailyWord()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.vertical, 16)
                
            case .idle:
                EmptyView()
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                QuickActionCard(
                    title: "Chat",
                    subtitle: "AI coach",
                    icon: "message.fill",
                    color: .blue
                ) {
                    // TODO: Navigate to chat
                }
                
                QuickActionCard(
                    title: "Wordbank",
                    subtitle: "Your collection",
                    icon: "book.fill",
                    color: .green
                ) {
                    // TODO: Navigate to wordbank
                }
                
                QuickActionCard(
                    title: "Interests",
                    subtitle: "Manage topics",
                    icon: "slider.horizontal.3",
                    color: .purple
                ) {
                    // TODO: Navigate to interests
                }
                
                QuickActionCard(
                    title: "Profile",
                    subtitle: "Settings & stats",
                    icon: "person.fill",
                    color: .orange
                ) {
                    // TODO: Navigate to profile
                }
            }
        }
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline)
                .fontWeight(.semibold)
            
            // TODO: Add recent activity items
            Text("Coming soon...")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.vertical, 16)
        }
    }
}

// MARK: - Supporting Views

private struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    EnhancedHomeView()
        .environmentObject(AuthManager.shared)
}
