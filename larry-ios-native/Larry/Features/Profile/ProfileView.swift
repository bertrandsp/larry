import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @EnvironmentObject private var apiService: APIService
    @State private var learningStats: LearningStats?
    @State private var isLoading = false
    @State private var showingSignOutAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    profileHeader
                    
                    // Learning statistics
                    if let stats = learningStats {
                        learningStatsView(stats)
                    }
                    
                    // Settings sections
                    settingsSection
                    
                    // Sign out button
                    signOutButton
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await loadLearningStats()
            }
        }
        .task {
            await loadLearningStats()
        }
        .alert("Sign Out", isPresented: $showingSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                Task {
                    await authManager.signOut()
                }
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Profile image placeholder
            Circle()
                .fill(Color.blue.gradient)
                .frame(width: 80, height: 80)
                .overlay {
                    if let user = authManager.currentUser {
                        Text(user.name?.prefix(1).uppercased() ?? user.email.prefix(1).uppercased())
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
            
            // User info
            VStack(spacing: 4) {
                if let user = authManager.currentUser {
                    if let name = user.name {
                        Text(name)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    Text(user.email)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    // Subscription status
                    if let subscription = user.subscriptionStatus {
                        Text(subscription.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(subscription == .free ? Color.gray : Color.blue)
                            .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    private func learningStatsView(_ stats: LearningStats) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Learning Progress")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Stats grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(
                    title: "Current Streak",
                    value: "\(stats.currentStreak)",
                    subtitle: "days",
                    icon: "flame.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Words Learned",
                    value: "\(stats.totalWordsLearned)",
                    subtitle: "total",
                    icon: "book.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Mastered",
                    value: "\(stats.totalWordsMastered)",
                    subtitle: "words",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Accuracy",
                    value: "\(Int(stats.averageAccuracy * 100))%",
                    subtitle: "average",
                    icon: "target",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 0) {
                SettingsRow(
                    title: "Notifications",
                    icon: "bell.fill",
                    action: { /* Handle notifications settings */ }
                )
                
                Divider()
                
                SettingsRow(
                    title: "Learning Preferences",
                    icon: "slider.horizontal.3",
                    action: { /* Handle learning preferences */ }
                )
                
                Divider()
                
                SettingsRow(
                    title: "Privacy",
                    icon: "lock.fill",
                    action: { /* Handle privacy settings */ }
                )
                
                Divider()
                
                SettingsRow(
                    title: "Help & Support",
                    icon: "questionmark.circle.fill",
                    action: { /* Handle help */ }
                )
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
    }
    
    private var signOutButton: some View {
        Button {
            showingSignOutAlert = true
        } label: {
            Text("Sign Out")
                .font(.headline)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    private func loadLearningStats() async {
        isLoading = true
        
        do {
            learningStats = try await apiService.getLearningStats()
        } catch {
            // Load mock stats for preview
            learningStats = LearningStats(
                currentStreak: 7,
                longestStreak: 15,
                totalWordsLearned: 156,
                totalWordsMastered: 42,
                favoriteWords: 23,
                averageAccuracy: 0.85,
                weeklyProgress: []
            )
        }
        
        isLoading = false
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct SettingsRow: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationManager())
        .environmentObject(APIService())
}
