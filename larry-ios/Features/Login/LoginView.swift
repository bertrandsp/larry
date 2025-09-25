//
//  LoginView.swift
//  larry-ios
//
//  Created by AI Assistant on 9/15/25.
//

import SwiftUI
import AuthenticationServices

/// Login screen with Apple and Google Sign-In options
struct LoginView: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingEmailAuth = false
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 32) {
                    Spacer()
                        .frame(height: geometry.size.height * 0.1)
                    
                    // App branding
                    VStack(spacing: 16) {
                        // App icon/logo placeholder
                        Circle()
                            .fill(Color.blue.gradient)
                            .frame(width: 120, height: 120)
                            .overlay {
                                Text("L")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        
                        VStack(spacing: 8) {
                            Text("Welcome to Larry")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Your AI-powered vocabulary coach")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    Spacer()
                        .frame(height: geometry.size.height * 0.1)
                    
                    // Sign-in options
                    VStack(spacing: 16) {
                        // Sign in with Apple
                        SignInWithAppleButton(.signIn) { request in
                            // Configure the request
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            Task {
                                await handleAppleSignInResult(result)
                            }
                        }
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 56)
                        .cornerRadius(28)
                        
                        // Sign in with Google
                        Button(action: {
                            Task {
                                await handleGoogleSignIn()
                            }
                        }) {
                            HStack(spacing: 12) {
                                // Google logo placeholder
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 24, height: 24)
                                    .overlay {
                                        Text("G")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.blue)
                                    }
                                
                                Text("Continue with Google")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                        }
                        .frame(height: 56)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .overlay {
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        }
                        .cornerRadius(28)
                        .disabled(authManager.authState.isLoading)
                        
                        // Email/Password Sign In
                        Button(action: {
                            isSignUp = false
                            showingEmailAuth = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                
                                Text("Sign In with Email")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(height: 56)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(28)
                        .disabled(authManager.authState.isLoading)
                        
                        // Create Account
                        Button(action: {
                            isSignUp = true
                            showingEmailAuth = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.badge.plus.fill")
                                    .foregroundColor(.green)
                                    .frame(width: 24, height: 24)
                                
                                Text("Create Account")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.green)
                            }
                        }
                        .frame(height: 56)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .overlay {
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.green, lineWidth: 2)
                        }
                        .cornerRadius(28)
                        .disabled(authManager.authState.isLoading)
                    }
                    .padding(.horizontal, 24)
                    
                    // Loading indicator
                    if authManager.authState.isLoading {
                        VStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(1.2)
                            
                            Text("Signing you in...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 16)
                    }
                    
                    Spacer()
                    
                    #if DEBUG
                    // Debug button to clear auth data
                    Button("Clear Auth Data (Debug)") {
                        authManager.clearAllAuthData()
                        authManager.forceRefreshAuthState()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.bottom, 16)
                    #endif
                    
                    // Privacy notice
                    VStack(spacing: 8) {
                        Text("By continuing, you agree to our")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 16) {
                            Button("Terms of Service") {
                                // TODO: Show terms
                            }
                            .font(.caption)
                            
                            Button("Privacy Policy") {
                                // TODO: Show privacy policy
                            }
                            .font(.caption)
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .alert("Sign In Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onChange(of: authManager.authState) { _, newState in
            if case .error(let errorString) = newState {
                errorMessage = errorString
                showingError = true
            }
        }
        .sheet(isPresented: $showingEmailAuth) {
            EmailAuthView(
                isSignUp: isSignUp,
                email: $email,
                password: $password,
                name: $name,
                onSubmit: { email, password, name in
                    Task {
                        await handleEmailAuth(email: email, password: password, name: name)
                    }
                },
                onCancel: {
                    showingEmailAuth = false
                    clearEmailFields()
                }
            )
            .environmentObject(authManager)
        }
    }
    
    // MARK: - Sign-In Handlers
    
    private func handleAppleSignInResult(_ result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success(let authorization):
            do {
                try await authManager.handleAppleSignInResult(authorization)
            } catch {
                print("Apple Sign-In error: \(error)")
            }
        case .failure(let error):
            print("Apple Sign-In failed: \(error)")
        }
    }
    
    private func handleGoogleSignIn() async {
        do {
            try await authManager.signInWithGoogle()
        } catch {
            // Error is already handled by AuthManager
            print("Google Sign-In error: \(error)")
        }
    }
    
    private func handleEmailAuth(email: String, password: String, name: String?) async {
        do {
            if isSignUp {
                try await authManager.signUpWithEmail(email, password: password, name: name)
            } else {
                try await authManager.signInWithEmail(email, password: password)
            }
            showingEmailAuth = false
            clearEmailFields()
        } catch {
            // Error is already handled by AuthManager
            print("Email auth error: \(error)")
        }
    }
    
    private func clearEmailFields() {
        email = ""
        password = ""
        name = ""
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager.shared)
}
