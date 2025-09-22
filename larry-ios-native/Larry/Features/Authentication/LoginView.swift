import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @State private var showingError = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBlue).opacity(0.1),
                        Color(.systemPurple).opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // App Logo and Title
                    VStack(spacing: 20) {
                        // Logo placeholder - replace with your actual logo
                        Image(systemName: "book.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            Text("Larry")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("AI-Powered Vocabulary Learning")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    Spacer()
                    
                    // Sign In Options
                    VStack(spacing: 16) {
                        // Sign in with Apple
                        SignInWithAppleButton(
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: { _ in
                                // Handle completion in AuthenticationManager
                                Task {
                                    await authManager.signInWithApple()
                                }
                            }
                        )
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 50)
                        .cornerRadius(25)
                        .disabled(authManager.isLoading)
                        
                        // Sign in with Google
                        Button {
                            Task {
                                await authManager.signInWithGoogle()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "globe")
                                    .font(.title3)
                                
                                Text("Continue with Google")
                                    .font(.headline)
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .disabled(authManager.isLoading)
                        
                        // Loading indicator
                        if authManager.isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Signing in...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Terms and Privacy
                    VStack(spacing: 8) {
                        Text("By continuing, you agree to our")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Button("Terms of Service") {
                                // Handle terms tap
                            }
                            .font(.caption)
                            
                            Text("and")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Button("Privacy Policy") {
                                // Handle privacy tap
                            }
                            .font(.caption)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 30)
            }
        }
        .alert("Sign In Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(authManager.errorMessage ?? "An unknown error occurred")
        }
        .onChange(of: authManager.errorMessage) { errorMessage in
            showingError = errorMessage != nil
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
}
