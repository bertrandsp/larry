//
//  RootView.swift
//  larry-ios
//
//  Created by AI Assistant on 9/15/25.
//

import SwiftUI

/// Root view that manages the main navigation flow based on authentication state
struct RootView: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var isInitializing = true
    
    var body: some View {
        Group {
            if isInitializing || authManager.authState == .validatingUser {
                // Show loading screen while checking authentication or validating user
                LoadingView(message: authManager.authState == .validatingUser ? "Validating..." : "Loading...")
            } else if authManager.isAuthenticated {
                if let user = authManager.currentUser, user.onboardingCompleted {
                    // User is authenticated and onboarded -> show main app
                    HomeView()
                } else {
                    // User is authenticated but needs onboarding
                    OnboardingView()
                }
            } else {
                // User is not authenticated -> show login
                LoginView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authManager.isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: authManager.currentUser?.onboardingCompleted)
        .animation(.easeInOut(duration: 0.3), value: authManager.authState == .validatingUser)
        .onAppear {
            #if DEBUG
            print("🏠 ===== ROOT VIEW APPEARED =====")
            print("🏠 Current state:")
            print("🏠   - isInitializing: \(isInitializing)")
            print("🏠   - isAuthenticated: \(authManager.isAuthenticated)")
            print("🏠   - currentUser: \(authManager.currentUser?.email ?? "nil")")
            print("🏠   - onboardingCompleted: \(authManager.currentUser?.onboardingCompleted ?? false)")
            print("🏠   - authState: \(authManager.authState)")
            print("🏠 ===== ROOT VIEW STATE =====")
            #endif
            
            // Give a small delay to ensure AuthManager has finished initialization
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isInitializing = false
                
                #if DEBUG
                print("🏠 Initialization delay complete - isInitializing set to false")
                print("🏠 Final state after initialization:")
                print("🏠   - isInitializing: \(isInitializing)")
                print("🏠   - isAuthenticated: \(authManager.isAuthenticated)")
                print("🏠   - currentUser: \(authManager.currentUser?.email ?? "nil")")
                print("🏠   - onboardingCompleted: \(authManager.currentUser?.onboardingCompleted ?? false)")
                print("🏠   - authState: \(authManager.authState)")
                #endif
            }
        }
        .onChange(of: authManager.isAuthenticated) { newValue in
            #if DEBUG
            print("🏠 🔄 isAuthenticated changed to: \(newValue)")
            #endif
        }
        .onChange(of: authManager.currentUser?.onboardingCompleted) { newValue in
            #if DEBUG
            print("🏠 🔄 onboardingCompleted changed to: \(newValue ?? false)")
            #endif
        }
        .onChange(of: authManager.authState) { newValue in
            #if DEBUG
            print("🏠 🔄 authState changed to: \(newValue)")
            #endif
        }
    }
}

/// Simple loading view shown during authentication check
struct LoadingView: View {
    let message: String
    
    init(message: String = "Loading...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    RootView()
        .environmentObject(AuthManager.shared)
}

