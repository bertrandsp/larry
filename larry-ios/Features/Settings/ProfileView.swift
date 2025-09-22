//
//  ProfileView.swift
//  larry-ios
//
//  Created by AI Assistant on 9/15/25.
//

import SwiftUI

/// User profile and settings view
struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // User info section
                Section {
                    if let user = authManager.currentUser {
                        HStack {
                            // Profile image placeholder
                            Circle()
                                .fill(Color.blue.gradient)
                                .frame(width: 60, height: 60)
                                .overlay {
                                    Text(user.name?.prefix(1).uppercased() ?? "U")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.name ?? "User")
                                    .font(.headline)
                                
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Text(user.subscription.displayName)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(user.subscription == .plus ? Color.orange : Color.gray)
                                        .foregroundColor(.white)
                                        .cornerRadius(4)
                                    
                                    Spacer()
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // Stats section
                Section("Learning Stats") {
                    if let user = authManager.currentUser {
                        StatRow(
                            title: "Words Learned",
                            value: "\(user.totalWordsLearned)",
                            icon: "book.fill"
                        )
                        
                        StatRow(
                            title: "Current Streak",
                            value: "\(user.streakCount) days",
                            icon: "flame.fill"
                        )
                        
                        StatRow(
                            title: "Subscription",
                            value: user.subscription.displayName,
                            icon: "star.fill"
                        )
                    }
                }
                
                // Settings section
                Section("Settings") {
                    SettingsRow(
                        title: "Interests & Topics",
                        icon: "slider.horizontal.3",
                        destination: InterestsView()
                    )
                    
                    SettingsRow(
                        title: "Notifications",
                        icon: "bell.fill",
                        destination: ComingSoonView(
                            title: "Notifications",
                            description: "Notification settings will be available here"
                        )
                    )
                    
                    SettingsRow(
                        title: "Learning Preferences",
                        icon: "gearshape.fill",
                        destination: ComingSoonView(
                            title: "Learning Preferences",
                            description: "Customize your learning experience"
                        )
                    )
                }
                
                // Support section
                Section("Support") {
                    SettingsRow(
                        title: "Help & FAQ",
                        icon: "questionmark.circle.fill",
                        destination: ComingSoonView(
                            title: "Help & FAQ",
                            description: "Get help and find answers to common questions"
                        )
                    )
                    
                    SettingsRow(
                        title: "Contact Support",
                        icon: "envelope.fill",
                        destination: ComingSoonView(
                            title: "Contact Support",
                            description: "Get in touch with our support team"
                        )
                    )
                    
                    SettingsRow(
                        title: "Privacy Policy",
                        icon: "hand.raised.fill",
                        destination: ComingSoonView(
                            title: "Privacy Policy",
                            description: "Read our privacy policy"
                        )
                    )
                }
                
                // Account section
                Section("Account") {
                    Button {
                        showingLogoutAlert = true
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Sign Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                Task {
                    await authManager.logout()
                }
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
}

// MARK: - Supporting Views

private struct StatRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

private struct SettingsRow<Destination: View>: View {
    let title: String
    let icon: String
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                Text(title)
            }
        }
    }
}

private struct InterestsView: View {
    var body: some View {
        ComingSoonView(
            title: "Interests & Topics",
            description: "Manage your learning topics and weights here"
        )
        .navigationTitle("Interests")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager.shared)
}

