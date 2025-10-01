//
//  HomeView.swift
//  larry-ios
//
//  Created by AI Assistant on 9/15/25.
//

import SwiftUI

/// Main home screen showing daily words and navigation
struct HomeView: View {
    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Header with user info and streak
                    headerSection
                    
                    // Daily words section
                    dailyWordsSection
                    
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
            }
            .refreshable {
                await viewModel.refreshData()
            }
        }
        .task {
            await viewModel.loadInitialData()
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let user = authManager.currentUser {
                    Text("Hello, \(user.name ?? "Learner")!")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("\(user.totalWordsLearned) words learned")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("Welcome back!")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }
            
            Spacer()
            
            // Streak counter
            VStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                Text("\(authManager.currentUser?.streakCount ?? 0)")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("day streak")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding(.horizontal, 4)
    }
    
    private var dailyWordsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Words")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if let remainingCount = viewModel.dailyWords.data?.remainingToday {
                    Text("\(remainingCount) remaining")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Enhanced first daily word section
            firstDailyWordSection
            
            // Regular daily words section
            switch viewModel.dailyWords {
            case .loading:
                ProgressView("Loading your words...")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                
            case .success(let response):
                if response.words.isEmpty {
                    emptyWordsView
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(response.words) { word in
                            DailyWordCard(dailyWord: word)
                        }
                    }
                }
                
            case .error(let error):
                ErrorView(
                    title: "Failed to load words",
                    message: error.localizedDescription,
                    retryAction: {
                        Task {
                            await viewModel.loadDailyWords()
                        }
                    }
                )
                
            case .idle:
                EmptyView()
            }
        }
    }
    
    private var firstDailyWordSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            switch viewModel.firstDailyWord {
            case .loading:
                ProgressView("Loading your first word...")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                
            case .success(let response):
                if let firstWord = response.dailyWord {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your First Word")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        EnhancedDailyWordCard(dailyWord: firstWord)
                    }
                } else {
                    EmptyView()
                }
                
            case .error(let error):
                ErrorView(
                    title: "Failed to load first word",
                    message: error.localizedDescription,
                    retryAction: {
                        Task {
                            await viewModel.loadFirstDailyWord()
                        }
                    }
                )
                
            case .idle:
                EmptyView()
            }
        }
    }
    
    private var emptyWordsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)
            
            Text("All caught up!")
                .font(.headline)
            
            Text("You've completed all your words for today. Great job!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 32)
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                QuickActionCard(
                    title: "Wordbank",
                    subtitle: "Review saved words",
                    icon: "book.fill",
                    color: .blue
                ) {
                    // TODO: Navigate to wordbank
                }
                
                QuickActionCard(
                    title: "Larry Chat",
                    subtitle: "Ask about words",
                    icon: "message.fill",
                    color: .green
                ) {
                    // TODO: Navigate to chat
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

private struct DailyWordCard: View {
    let dailyWord: DailyWord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dailyWord.term.word)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(dailyWord.term.partOfSpeechEnum.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray5))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                if dailyWord.isReview {
                    Text("REVIEW")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            
            Text(dailyWord.term.definition)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            if let example = dailyWord.term.exampleSentence {
                Text("\"\(example)\"")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
            }
            
            // Action buttons
            HStack(spacing: 16) {
                Button("❤️ Favorite") {
                    // TODO: Add to favorites
                }
                .font(.caption)
                
                Button("🔄 Learn Again") {
                    // TODO: Mark for re-learning
                }
                .font(.caption)
                
                Button("✅ Mastered") {
                    // TODO: Mark as mastered
                }
                .font(.caption)
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

private struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                    
                    Spacer()
                }
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct ErrorView: View {
    let title: String
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundColor(.orange)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 32)
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager.shared)
}
