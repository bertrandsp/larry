import Foundation
import AuthenticationServices
import GoogleSignIn
import UIKit

/// Main authentication manager handling Sign in with Apple and Google Sign In
@MainActor
final class AuthenticationManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let keychainService: KeychainService
    private let apiService: APIService
    
    // MARK: - Initialization
    
    override init() {
        self.keychainService = KeychainService()
        self.apiService = APIService()
        super.init()
        
        print("🔐 AuthenticationManager initialized")
    }
    
    // MARK: - Authentication State Management
    
    /// Check current authentication state on app launch
    func checkAuthenticationState() async {
        print("🔍 Checking authentication state...")
        
        isLoading = true
        defer { isLoading = false }
        
        // Check if we have valid credentials in keychain
        guard keychainService.hasValidCredentials() else {
            print("❌ No valid credentials found")
            await signOut()
            return
        }
        
        // Check if token is expired and try to refresh
        if keychainService.isTokenExpired() {
            print("⏰ Token expired, attempting refresh...")
            await refreshTokens()
            return
        }
        
        // Try to fetch user profile to validate authentication
        do {
            let user = try await apiService.getUserProfile()
            currentUser = user
            isAuthenticated = true
            print("✅ User authenticated: \(user.email)")
        } catch {
            print("❌ Failed to fetch user profile: \(error)")
            await handleAuthenticationError(error)
        }
    }
    
    /// Refresh authentication tokens
    private func refreshTokens() async {
        do {
            let tokenResponse = try await apiService.refreshTokens()
            try keychainService.storeTokens(
                accessToken: tokenResponse.accessToken,
                refreshToken: tokenResponse.refreshToken,
                expiresIn: tokenResponse.expiresIn
            )
            
            // Fetch updated user profile
            let user = try await apiService.getUserProfile()
            currentUser = user
            isAuthenticated = true
            print("✅ Tokens refreshed successfully")
            
        } catch {
            print("❌ Token refresh failed: \(error)")
            await signOut()
        }
    }
    
    // MARK: - Sign in with Apple
    
    /// Initiate Sign in with Apple flow
    func signInWithApple() async {
        print("🍎 Starting Sign in with Apple...")
        
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            let appleIDCredential = try await performAppleSignIn()
            
            guard let identityToken = appleIDCredential.identityToken,
                  let identityTokenString = String(data: identityToken, encoding: .utf8),
                  let authorizationCode = appleIDCredential.authorizationCode,
                  let authCodeString = String(data: authorizationCode, encoding: .utf8) else {
                throw AuthenticationError.invalidAppleCredentials
            }
            
            // Send credentials to backend
            let authResponse = try await apiService.signInWithApple(
                identityToken: identityTokenString,
                authorizationCode: authCodeString
            )
            
            // Store tokens and user data
            try keychainService.storeTokens(
                accessToken: authResponse.accessToken,
                refreshToken: authResponse.refreshToken,
                expiresIn: authResponse.expiresIn
            )
            
            try keychainService.storeUserData(
                userId: authResponse.user.id,
                email: authResponse.user.email
            )
            
            // Update UI state
            currentUser = authResponse.user
            isAuthenticated = true
            
            print("✅ Apple Sign In successful: \(authResponse.user.email)")
            
        } catch {
            print("❌ Apple Sign In failed: \(error)")
            errorMessage = error.localizedDescription
        }
    }
    
    /// Perform Apple Sign In request
    private func performAppleSignIn() async throws -> ASAuthorizationAppleIDCredential {
        return try await withCheckedThrowingContinuation { continuation in
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            
            let delegate = AppleSignInDelegate { result in
                continuation.resume(with: result)
            }
            
            controller.delegate = delegate
            controller.presentationContextProvider = delegate
            controller.performRequests()
        }
    }
    
    // MARK: - Google Sign In
    
    /// Initiate Google Sign In flow
    func signInWithGoogle() async {
        print("🔍 Starting Google Sign In...")
        
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            // Get the root view controller
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                throw AuthenticationError.noRootViewController
            }
            
            // Perform Google Sign In
            guard let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) else {
                throw AuthenticationError.googleSignInCancelled
            }
            
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthenticationError.invalidGoogleCredentials
            }
            
            // For Google Sign In, we'll need to implement the backend flow
            // This is a simplified version - you may need to adjust based on your backend implementation
            let authResponse = try await handleGoogleSignIn(idToken: idToken)
            
            // Store tokens and user data
            try keychainService.storeTokens(
                accessToken: authResponse.accessToken,
                refreshToken: authResponse.refreshToken,
                expiresIn: authResponse.expiresIn
            )
            
            try keychainService.storeUserData(
                userId: authResponse.user.id,
                email: authResponse.user.email
            )
            
            // Update UI state
            currentUser = authResponse.user
            isAuthenticated = true
            
            print("✅ Google Sign In successful: \(authResponse.user.email)")
            
        } catch {
            print("❌ Google Sign In failed: \(error)")
            errorMessage = error.localizedDescription
        }
    }
    
    /// Handle Google Sign In with backend
    private func handleGoogleSignIn(idToken: String) async throws -> AuthResponse {
        // This is a simplified implementation
        // You may need to adjust this based on your backend's Google OAuth flow
        
        // First, get the auth URL from your backend
        let googleResponse = try await apiService.startGoogleSignIn()
        
        // For now, we'll create a mock response
        // In a real implementation, you'd complete the OAuth flow with your backend
        throw AuthenticationError.googleSignInNotImplemented
    }
    
    // MARK: - Sign Out
    
    /// Sign out current user
    func signOut() async {
        print("👋 Signing out user...")
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Clear keychain data
            try keychainService.clearAllData()
            
            // Sign out from Google if applicable
            GIDSignIn.sharedInstance.signOut()
            
            // Update UI state
            currentUser = nil
            isAuthenticated = false
            errorMessage = nil
            
            print("✅ User signed out successfully")
            
        } catch {
            print("❌ Sign out error: \(error)")
            // Even if keychain clearing fails, update UI state
            currentUser = nil
            isAuthenticated = false
        }
    }
    
    // MARK: - Error Handling
    
    private func handleAuthenticationError(_ error: Error) async {
        if case APIError.authenticationRequired = error {
            await signOut()
        } else {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Debug Helpers
    
    #if DEBUG
    func debugPrintAuthState() {
        print("🔐 Authentication State:")
        print("  - Is Authenticated: \(isAuthenticated)")
        print("  - Current User: \(currentUser?.email ?? "None")")
        print("  - Is Loading: \(isLoading)")
        print("  - Error Message: \(errorMessage ?? "None")")
        keychainService.debugPrintKeychainState()
    }
    #endif
}

// MARK: - Apple Sign In Delegate

private class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    private let completion: (Result<ASAuthorizationAppleIDCredential, Error>) -> Void
    
    init(completion: @escaping (Result<ASAuthorizationAppleIDCredential, Error>) -> Void) {
        self.completion = completion
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            completion(.success(appleIDCredential))
        } else {
            completion(.failure(AuthenticationError.invalidAppleCredentials))
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion(.failure(error))
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
}

// MARK: - Authentication Errors

enum AuthenticationError: LocalizedError {
    case invalidAppleCredentials
    case invalidGoogleCredentials
    case noRootViewController
    case googleSignInCancelled
    case googleSignInNotImplemented
    
    var errorDescription: String? {
        switch self {
        case .invalidAppleCredentials:
            return "Invalid Apple credentials received."
        case .invalidGoogleCredentials:
            return "Invalid Google credentials received."
        case .noRootViewController:
            return "Unable to present sign-in interface."
        case .googleSignInCancelled:
            return "Google Sign In was cancelled."
        case .googleSignInNotImplemented:
            return "Google Sign In flow needs to be completed based on your backend implementation."
        }
    }
}
