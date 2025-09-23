//
//  AuthManager.swift
//  larry-ios
//
//  Created by AI Assistant on 9/15/25.
//

import Foundation
import AuthenticationServices
import SwiftUI
import UIKit
// import GoogleSignIn // TODO: Add GoogleSignIn dependency to Xcode project
// import KeychainAccess // TODO: Add KeychainAccess dependency to Xcode project
import Combine

/// Manages user authentication state and operations
@MainActor
class AuthManager: NSObject, ObservableObject {
    static let shared = AuthManager()
    
    // MARK: - Published Properties
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var authState: AuthState = .idle
    
    // MARK: - Private Properties
    
    // TODO: Replace with KeychainAccess when dependency is added
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    // App lifecycle monitoring
    @Published var isValidatingUser = false
    
    // MARK: - Keychain Keys
    
    private enum KeychainKeys {
        static let accessToken = "access_token"
        static let refreshToken = "refresh_token"
        static let userID = "user_id"
    }
    
    // MARK: - Authentication State
    
    enum AuthState: Equatable {
        case idle
        case signingIn
        case refreshingToken
        case signingOut
        case validatingUser
        case error(String) // Changed from Error to String for Equatable conformance
        
        var isLoading: Bool {
            switch self {
            case .signingIn, .refreshingToken, .signingOut, .validatingUser:
                return true
            default:
                return false
            }
        }
        
        static func == (lhs: AuthState, rhs: AuthState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle),
                 (.signingIn, .signingIn),
                 (.refreshingToken, .refreshingToken),
                 (.signingOut, .signingOut),
                 (.validatingUser, .validatingUser):
                return true
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError == rhsError
            default:
                return false
            }
        }
    }
    
    // MARK: - Token Properties
    
    var accessToken: String? {
        return userDefaults.string(forKey: KeychainKeys.accessToken)
    }
    
    private var refreshTokenValue: String? {
        return userDefaults.string(forKey: KeychainKeys.refreshToken)
    }
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        checkAuthenticationState()
        setupAppLifecycleMonitoring()
        
        #if DEBUG
        print("🔐 AuthManager initialized")
        #endif
    }
    
    // MARK: - Authentication State Management
    
    private func checkAuthenticationState() {
        #if DEBUG
        print("🔍 ===== CHECKING AUTHENTICATION STATE =====")
        print("🔍 Current state before check:")
        print("🔍   - isAuthenticated: \(isAuthenticated)")
        print("🔍   - currentUser: \(currentUser?.email ?? "nil")")
        print("🔍   - authState: \(authState)")
        #endif
        
        // Force clear any existing state first
        isAuthenticated = false
        currentUser = nil
        
        if let token = accessToken, !token.isEmpty {
            #if DEBUG
            print("🔑 Found access token: \(token.prefix(10))...")
            print("🔑 Token length: \(token.count) characters")
            #endif
            
            // Validate token by fetching user profile
            Task {
                await fetchUserProfile()
            }
        } else {
            #if DEBUG
            print("❌ No access token found")
            print("❌ Access token value: \(accessToken ?? "nil")")
            print("❌ Setting authenticated = false")
            #endif
            isAuthenticated = false
            currentUser = nil
        }
        
        #if DEBUG
        print("🔐 Final auth state after check:")
        print("🔐   - isAuthenticated: \(isAuthenticated)")
        print("🔐   - currentUser: \(currentUser?.email ?? "nil")")
        print("🔐   - authState: \(authState)")
        print("🔐 ===== AUTHENTICATION STATE CHECK COMPLETE =====")
        #endif
    }
    
    // MARK: - Sign In with Apple
    
    func handleAppleSignInResult(_ authorization: ASAuthorization) async throws {
        #if DEBUG
        print("🍎 ===== APPLE SIGN IN STARTED =====")
        #endif
        
        authState = .signingIn
        
        do {
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityTokenData = appleIDCredential.identityToken,
                  let identityToken = String(data: identityTokenData, encoding: .utf8),
                  let authorizationCodeData = appleIDCredential.authorizationCode,
                  let authorizationCode = String(data: authorizationCodeData, encoding: .utf8) else {
                #if DEBUG
                print("🍎 ❌ Failed to extract Apple credentials")
                #endif
                throw AuthError.appleSignInFailed
            }
            
            #if DEBUG
            print("🍎 ✅ Apple credentials extracted successfully")
            print("🍎   - Email: \(appleIDCredential.email ?? "nil")")
            print("🍎   - User ID: \(appleIDCredential.user)")
            print("🍎   - Identity token length: \(identityToken.count)")
            print("🍎   - Authorization code length: \(authorizationCode.count)")
            #endif
            
            // Send Apple credentials to backend
            let authRequest = AppleAuthRequest(
                identityToken: identityToken,
                authorizationCode: authorizationCode,
                fullName: appleIDCredential.fullName,
                email: appleIDCredential.email
            )
            
            #if DEBUG
            print("🍎 Making API request to: /auth-direct/apple")
            #endif
            
            let apiRequest = try APIRequest(
                method: .POST,
                path: "/auth-direct/apple",
                body: authRequest
            )
            
            let response: AuthResponse = try await APIService.shared.send(
                apiRequest,
                responseType: AuthResponse.self
            )
            
            #if DEBUG
            print("🍎 ✅ API call successful!")
            print("🍎   - Access token received: \(response.accessToken.prefix(10))...")
            print("🍎   - User: \(response.user?.email ?? "nil")")
            #endif
            
            await handleSuccessfulAuth(response)
            
            #if DEBUG
            print("🍎 ===== APPLE SIGN IN SUCCESSFUL =====")
            #endif
            
        } catch {
            #if DEBUG
            print("🍎 ❌ ===== APPLE SIGN IN FAILED =====")
            print("🍎 Error details:")
            print("🍎   - Error type: \(type(of: error))")
            print("🍎   - Error description: \(error.localizedDescription)")
            print("🍎   - Full error: \(error)")
            #endif
            
            authState = .error(error.localizedDescription)
            throw error
        }
    }
    
    // MARK: - Sign In with Google
    
    func signInWithGoogle() async throws {
        // TODO: Implement Google Sign-In when GoogleSignIn dependency is added
        throw AuthError.googleSignInFailed
    }
    
    // MARK: - Token Refresh
    
    func refreshToken() async throws {
        guard let refreshToken = refreshTokenValue else {
            throw AuthError.noRefreshToken
        }
        
        authState = .refreshingToken
        
        do {
            let request = RefreshTokenRequest(refreshToken: refreshToken)
            let apiRequest = try APIRequest(
                method: .POST,
                path: "/auth-direct/refresh",
                body: request
            )
            
            let response: AuthResponse = try await APIService.shared.send(
                apiRequest,
                responseType: AuthResponse.self
            )
            
            // Store new tokens
            userDefaults.set(response.accessToken, forKey: KeychainKeys.accessToken)
            if let newRefreshToken = response.refreshToken {
                userDefaults.set(newRefreshToken, forKey: KeychainKeys.refreshToken)
            }
            
            authState = .idle
            
            #if DEBUG
            print("✅ Token refreshed successfully")
            #endif
            
        } catch {
            authState = .error(error.localizedDescription)
            await logout() // Force logout on refresh failure
            throw error
        }
    }
    
    // MARK: - Logout
    
    func logout() async {
        #if DEBUG
        print("👋 ===== LOGGING OUT USER =====")
        print("👋 Current state before logout:")
        print("👋   - isAuthenticated: \(isAuthenticated)")
        print("👋   - currentUser: \(currentUser?.email ?? "nil")")
        print("👋   - authState: \(authState)")
        #endif
        
        authState = .signingOut
        
        // Clear stored tokens
        userDefaults.removeObject(forKey: KeychainKeys.accessToken)
        userDefaults.removeObject(forKey: KeychainKeys.refreshToken)
        userDefaults.removeObject(forKey: KeychainKeys.userID)
        
        // Clear state
        isAuthenticated = false
        currentUser = nil
        authState = .idle
        
        // Sign out from Google if needed
        // TODO: Uncomment when GoogleSignIn dependency is added
        // GIDSignIn.sharedInstance.signOut()
        
        #if DEBUG
        print("👋 ✅ User logged out successfully")
        print("👋 Final state after logout:")
        print("👋   - isAuthenticated: \(isAuthenticated)")
        print("👋   - currentUser: \(currentUser?.email ?? "nil")")
        print("👋   - authState: \(authState)")
        print("👋 ===== LOGOUT COMPLETE =====")
        #endif
    }
    
    // MARK: - Clear All Auth Data (for debugging/testing)
    
    func clearAllAuthData() {
        #if DEBUG
        print("🧹 Clearing all authentication data...")
        #endif
        
        // Clear stored tokens
        userDefaults.removeObject(forKey: KeychainKeys.accessToken)
        userDefaults.removeObject(forKey: KeychainKeys.refreshToken)
        userDefaults.removeObject(forKey: KeychainKeys.userID)
        
        // Clear state
        isAuthenticated = false
        currentUser = nil
        authState = .idle
        
        #if DEBUG
        print("✅ All authentication data cleared")
        #endif
    }
    
    // MARK: - Force Refresh Auth State
    
    func forceRefreshAuthState() {
        #if DEBUG
        print("🔄 Force refreshing authentication state...")
        #endif
        
        checkAuthenticationState()
    }
    
    // MARK: - App Lifecycle Monitoring
    
    private func setupAppLifecycleMonitoring() {
        // Monitor app lifecycle events
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.handleAppWillEnterForeground()
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.handleAppDidBecomeActive()
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleAppWillEnterForeground() async {
        #if DEBUG
        print("📱 ===== APP WILL ENTER FOREGROUND =====")
        print("📱 Current state before validation:")
        print("📱   - isAuthenticated: \(isAuthenticated)")
        print("📱   - currentUser: \(currentUser?.email ?? "nil")")
        print("📱   - authState: \(authState)")
        print("📱   - hasAccessToken: \(accessToken != nil)")
        #endif
        
        await validateUserInDatabase()
    }
    
    private func handleAppDidBecomeActive() async {
        #if DEBUG
        print("📱 ===== APP DID BECOME ACTIVE =====")
        print("📱 Current state before validation:")
        print("📱   - isAuthenticated: \(isAuthenticated)")
        print("📱   - currentUser: \(currentUser?.email ?? "nil")")
        print("📱   - authState: \(authState)")
        print("📱   - hasAccessToken: \(accessToken != nil)")
        #endif
        
        await validateUserInDatabase()
    }
    
    // MARK: - User Database Validation
    
    /// Validates that the currently logged-in user still exists in the database
    /// This is called automatically on app lifecycle events
    func validateUserInDatabase() async {
        #if DEBUG
        print("🔍 ===== VALIDATING USER IN DATABASE =====")
        print("🔍 Validation conditions check:")
        print("🔍   - isAuthenticated: \(isAuthenticated)")
        print("🔍   - hasAccessToken: \(accessToken != nil)")
        print("🔍   - tokenNotEmpty: \(accessToken?.isEmpty == false)")
        print("🔍   - notAlreadyValidating: \(authState != .validatingUser)")
        #endif
        
        // Only validate if we think we're authenticated and have a token
        guard isAuthenticated, 
              let token = accessToken, 
              !token.isEmpty,
              authState != .validatingUser else {
            #if DEBUG
            print("⏭️ Skipping user validation:")
            if !isAuthenticated { print("⏭️   - Reason: Not authenticated") }
            if accessToken == nil { print("⏭️   - Reason: No access token") }
            if accessToken?.isEmpty == true { print("⏭️   - Reason: Access token is empty") }
            if authState == .validatingUser { print("⏭️   - Reason: Already validating") }
            print("⏭️ ===== VALIDATION SKIPPED =====")
            #endif
            return
        }
        
        authState = .validatingUser
        isValidatingUser = true
        
        #if DEBUG
        print("🔍 Starting user validation...")
        print("🔍 Making API call to /auth-direct/profile")
        #endif
        
        do {
            let apiRequest = APIRequest(
                method: .GET,
                path: "/auth-direct/profile"
            )
            
            let user: User = try await APIService.shared.send(
                apiRequest,
                responseType: User.self
            )
            
            #if DEBUG
            print("🔍 ✅ API call successful!")
            print("🔍 User data received:")
            print("🔍   - ID: \(user.id)")
            print("🔍   - Email: \(user.email)")
            print("🔍   - Onboarding completed: \(user.onboardingCompleted)")
            #endif
            
            // User exists in database - update current user info
            currentUser = user
            userDefaults.set(user.id, forKey: KeychainKeys.userID)
            authState = .idle
            isValidatingUser = false
            
            #if DEBUG
            print("🔍 ✅ User validation successful: \(user.email)")
            print("🔍 ===== VALIDATION SUCCESSFUL =====")
            #endif
            
        } catch {
            #if DEBUG
            print("🔍 ❌ ===== VALIDATION FAILED =====")
            print("🔍 Error details:")
            print("🔍   - Error type: \(type(of: error))")
            print("🔍   - Error description: \(error.localizedDescription)")
            print("🔍   - Full error: \(error)")
            print("🔍 🚪 User no longer exists in database - logging out...")
            #endif
            
            // User doesn't exist in database or other error - force logout
            await logout()
            
            #if DEBUG
            print("🔍 ❌ ===== VALIDATION FAILED - LOGGED OUT =====")
            #endif
        }
    }
    
    /// Manual validation that can be called from UI (e.g., refresh button)
    /// Forces validation even if one is already in progress
    func forceValidateUserInDatabase() async {
        #if DEBUG
        print("🔄 Force validating user in database...")
        #endif
        
        guard let token = accessToken, !token.isEmpty else {
            #if DEBUG
            print("❌ No access token for force validation")
            #endif
            await logout()
            return
        }
        
        authState = .validatingUser
        isValidatingUser = true
        
        do {
            let apiRequest = APIRequest(
                method: .GET,
                path: "/auth-direct/profile"
            )
            
            let user: User = try await APIService.shared.send(
                apiRequest,
                responseType: User.self
            )
            
            // User exists in database - update current user info
            isAuthenticated = true
            currentUser = user
            userDefaults.set(user.id, forKey: KeychainKeys.userID)
            authState = .idle
            isValidatingUser = false
            
            #if DEBUG
            print("✅ Force user validation successful: \(user.email)")
            #endif
            
        } catch {
            #if DEBUG
            print("❌ Force user validation failed: \(error)")
            print("🚪 User no longer exists in database - logging out...")
            #endif
            
            // User doesn't exist in database or other error - force logout
            await logout()
        }
    }
    
    // MARK: - User Profile
    
    private func fetchUserProfile() async {
        #if DEBUG
        print("👤 ===== FETCHING USER PROFILE =====")
        print("👤 Starting profile fetch...")
        #endif
        
        do {
            let apiRequest = APIRequest(
                method: .GET,
                path: "/auth-direct/profile"
            )
            
            #if DEBUG
            print("👤 Making API request to: /auth-direct/profile")
            #endif
            
            let user: User = try await APIService.shared.send(
                apiRequest,
                responseType: User.self
            )
            
            #if DEBUG
            print("👤 ✅ API call successful!")
            print("👤 User data received:")
            print("👤   - ID: \(user.id)")
            print("👤   - Email: \(user.email)")
            print("👤   - Onboarding completed: \(user.onboardingCompleted)")
            #endif
            
            // Only set authenticated if we successfully fetched the user
            isAuthenticated = true
            currentUser = user
            userDefaults.set(user.id, forKey: KeychainKeys.userID)
            
            #if DEBUG
            print("👤 ✅ User profile fetched successfully, setting authenticated = true")
            print("👤 ===== USER PROFILE FETCH COMPLETE =====")
            #endif
            
        } catch {
            #if DEBUG
            print("👤 ❌ ===== USER PROFILE FETCH FAILED =====")
            print("👤 Error details:")
            print("👤   - Error type: \(type(of: error))")
            print("👤   - Error description: \(error.localizedDescription)")
            print("👤   - Full error: \(error)")
            #endif
            
            // Clear authentication state on profile fetch failure
            isAuthenticated = false
            currentUser = nil
            authState = .error(error.localizedDescription)
            
            #if DEBUG
            print("👤 ❌ Cleared authentication state due to profile fetch failure")
            print("👤 ===== USER PROFILE FETCH FAILED =====")
            #endif
        }
    }
    
    // MARK: - Private Helpers
    
    private func handleSuccessfulAuth(_ response: AuthResponse) async {
        // Store tokens
        userDefaults.set(response.accessToken, forKey: KeychainKeys.accessToken)
        if let refreshToken = response.refreshToken {
            userDefaults.set(refreshToken, forKey: KeychainKeys.refreshToken)
        }
        
        // Update state
        isAuthenticated = true
        currentUser = response.user
        authState = .idle
        
        if let user = response.user {
            userDefaults.set(user.id, forKey: KeychainKeys.userID)
        }
        
        #if DEBUG
        print("✅ Authentication successful")
        #endif
    }
}

// MARK: - Request/Response Models

private struct AppleAuthRequest: Codable {
    let identityToken: String
    let authorizationCode: String
    let fullName: PersonNameComponents?
    let email: String?
}

private struct GoogleAuthRequest: Codable {
    let idToken: String
    let accessToken: String
}

private struct RefreshTokenRequest: Codable {
    let refreshToken: String
}

private struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String?
    let user: User?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case user
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case noPresentingViewController
    case googleSignInFailed
    case noGoogleIDToken
    case noRefreshToken
    case appleSignInCancelled
    case appleSignInFailed
    
    var errorDescription: String? {
        switch self {
        case .noPresentingViewController:
            return "Unable to present sign-in view"
        case .googleSignInFailed:
            return "Google Sign-In failed"
        case .noGoogleIDToken:
            return "Failed to get Google ID token"
        case .noRefreshToken:
            return "No refresh token available"
        case .appleSignInCancelled:
            return "Apple Sign-In was cancelled"
        case .appleSignInFailed:
            return "Apple Sign-In failed"
        }
    }
}

