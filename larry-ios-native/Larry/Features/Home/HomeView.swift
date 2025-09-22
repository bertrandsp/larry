import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @EnvironmentObject private var apiService: APIService
    @State private var dailyWords: [DailyWord] = []
    @State private var currentStreak = 0
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with greeting and streak
                    headerView
                    
                    if isLoading {
                        loadingView
                    } else if dailyWords.isEmpty {
                        emptyStateView
                    } else {
                        // Daily words
                        ForEach(dailyWords) { dailyWord in
                            DailyWordCard(dailyWord: dailyWord) { action in
                                await handleWordAction(action, for: dailyWord)
                            }
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Daily Words")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await loadDailyWords()
            }
        }
        .task {
            await loadDailyWords()
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greetingText)
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    if let userName = authManager.currentUser?.name {
                        Text(userName)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                }
                
                Spacer()
                
                // Streak indicator
                VStack {
                    Image(systemName: "flame.fill")
                        .font(.title)
                        .foregroundColor(.orange)
                    
                    Text("\(currentStreak)")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("day streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            Divider()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading your daily words...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 50)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No words for today")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Check back tomorrow for new vocabulary!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Refresh") {
                Task {
                    await loadDailyWords()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.top, 50)
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good morning,"
        case 12..<17:
            return "Good afternoon,"
        default:
            return "Good evening,"
        }
    }
    
    private func loadDailyWords() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.getDailyWords()
            dailyWords = response.dailyWords
            currentStreak = response.streak
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func handleWordAction(_ action: UserAction, for dailyWord: DailyWord) async {
        do {
            _ = try await apiService.performDailyWordAction(action: action, dailyWordId: dailyWord.id)
            // Refresh the daily words after action
            await loadDailyWords()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct DailyWordCard: View {
    let dailyWord: DailyWord
    let onAction: (UserAction) async -> Void
    
    @State private var isExpanded = false
    @State private var showingActions = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Word header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dailyWord.term.word)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let partOfSpeech = dailyWord.term.partOfSpeech {
                        Text(partOfSpeech.abbreviation)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray5))
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                // Difficulty indicator
                Circle()
                    .fill(colorForDifficulty(dailyWord.term.difficulty))
                    .frame(width: 12, height: 12)
            }
            
            // Definition
            Text(dailyWord.term.definition)
                .font(.body)
                .lineLimit(isExpanded ? nil : 3)
            
            // Examples (if expanded)
            if isExpanded, let examples = dailyWord.term.examples, !examples.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Examples:")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    ForEach(examples.prefix(2), id: \.self) { example in
                        Text("• \(example)")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Action buttons
            HStack {
                Button(isExpanded ? "Show Less" : "Show More") {
                    withAnimation(.easeInOut) {
                        isExpanded.toggle()
                    }
                }
                .font(.caption)
                .foregroundColor(.blue)
                
                Spacer()
                
                Button("Actions") {
                    showingActions = true
                }
                .font(.caption)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .confirmationDialog("Choose Action", isPresented: $showingActions) {
            ForEach(UserAction.allCases, id: \.self) { action in
                Button(action.displayName) {
                    Task {
                        await onAction(action)
                    }
                }
            }
            
            Button("Cancel", role: .cancel) { }
        }
    }
    
    private func colorForDifficulty(_ difficulty: DifficultyLevel) -> Color {
        switch difficulty {
        case .beginner:
            return .green
        case .intermediate:
            return .yellow
        case .advanced:
            return .orange
        case .expert:
            return .red
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthenticationManager())
        .environmentObject(APIService())
}
