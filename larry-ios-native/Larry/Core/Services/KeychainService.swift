import Foundation
import KeychainAccess

/// Service for securely storing and retrieving sensitive data using iOS Keychain
final class KeychainService {
    
    // MARK: - Properties
    
    private let keychain: Keychain
    
    // MARK: - Keys
    
    private enum Keys {
        static let accessToken = "larry.access_token"
        static let refreshToken = "larry.refresh_token"
        static let userId = "larry.user_id"
        static let userEmail = "larry.user_email"
        static let tokenExpirationDate = "larry.token_expiration_date"
    }
    
    // MARK: - Initialization
    
    init() {
        // Initialize keychain with service identifier
        keychain = Keychain(service: "com.larry.app")
            .synchronizable(false) // Don't sync with iCloud for security
            .accessibility(.whenUnlockedThisDeviceOnly) // Only accessible when device is unlocked
    }
    
    // MARK: - Token Management
    
    /// Store authentication tokens securely
    func storeTokens(accessToken: String, refreshToken: String, expiresIn: Int) throws {
        do {
            try keychain.set(accessToken, key: Keys.accessToken)
            try keychain.set(refreshToken, key: Keys.refreshToken)
            
            // Calculate and store expiration date
            let expirationDate = Date().addingTimeInterval(TimeInterval(expiresIn))
            let expirationData = try JSONEncoder().encode(expirationDate)
            try keychain.set(expirationData, key: Keys.tokenExpirationDate)
            
            print("✅ Tokens stored successfully in keychain")
        } catch {
            print("❌ Failed to store tokens in keychain: \(error)")
            throw KeychainError.storageError(error)
        }
    }
    
    /// Retrieve access token from keychain
    func getAccessToken() -> String? {
        do {
            return try keychain.get(Keys.accessToken)
        } catch {
            print("❌ Failed to retrieve access token: \(error)")
            return nil
        }
    }
    
    /// Retrieve refresh token from keychain
    func getRefreshToken() -> String? {
        do {
            return try keychain.get(Keys.refreshToken)
        } catch {
            print("❌ Failed to retrieve refresh token: \(error)")
            return nil
        }
    }
    
    /// Check if access token is expired
    func isTokenExpired() -> Bool {
        guard let expirationData = try? keychain.getData(Keys.tokenExpirationDate),
              let expirationDate = try? JSONDecoder().decode(Date.self, from: expirationData) else {
            return true // Assume expired if we can't get expiration date
        }
        
        // Add 5-minute buffer before actual expiration
        let bufferTime: TimeInterval = 5 * 60
        return Date().addingTimeInterval(bufferTime) >= expirationDate
    }
    
    /// Get token expiration date
    func getTokenExpirationDate() -> Date? {
        guard let expirationData = try? keychain.getData(Keys.tokenExpirationDate),
              let expirationDate = try? JSONDecoder().decode(Date.self, from: expirationData) else {
            return nil
        }
        return expirationDate
    }
    
    // MARK: - User Data Management
    
    /// Store user identification data
    func storeUserData(userId: String, email: String) throws {
        do {
            try keychain.set(userId, key: Keys.userId)
            try keychain.set(email, key: Keys.userEmail)
            print("✅ User data stored successfully in keychain")
        } catch {
            print("❌ Failed to store user data in keychain: \(error)")
            throw KeychainError.storageError(error)
        }
    }
    
    /// Retrieve stored user ID
    func getUserId() -> String? {
        do {
            return try keychain.get(Keys.userId)
        } catch {
            print("❌ Failed to retrieve user ID: \(error)")
            return nil
        }
    }
    
    /// Retrieve stored user email
    func getUserEmail() -> String? {
        do {
            return try keychain.get(Keys.userEmail)
        } catch {
            print("❌ Failed to retrieve user email: \(error)")
            return nil
        }
    }
    
    // MARK: - Authentication State
    
    /// Check if user has valid authentication credentials
    func hasValidCredentials() -> Bool {
        guard let _ = getAccessToken(),
              let _ = getRefreshToken(),
              let _ = getUserId() else {
            return false
        }
        
        return true
    }
    
    /// Clear all stored authentication data
    func clearAllData() throws {
        do {
            try keychain.remove(Keys.accessToken)
            try keychain.remove(Keys.refreshToken)
            try keychain.remove(Keys.userId)
            try keychain.remove(Keys.userEmail)
            try keychain.remove(Keys.tokenExpirationDate)
            print("✅ All keychain data cleared successfully")
        } catch {
            print("❌ Failed to clear keychain data: \(error)")
            throw KeychainError.deletionError(error)
        }
    }
    
    // MARK: - Debug Helpers
    
    #if DEBUG
    /// Print current keychain state for debugging
    func debugPrintKeychainState() {
        print("🔐 Keychain State:")
        print("  - Access Token: \(getAccessToken() != nil ? "✅ Present" : "❌ Missing")")
        print("  - Refresh Token: \(getRefreshToken() != nil ? "✅ Present" : "❌ Missing")")
        print("  - User ID: \(getUserId() ?? "❌ Missing")")
        print("  - User Email: \(getUserEmail() ?? "❌ Missing")")
        print("  - Token Expired: \(isTokenExpired() ? "❌ Yes" : "✅ No")")
        if let expirationDate = getTokenExpirationDate() {
            print("  - Token Expires: \(expirationDate)")
        }
    }
    #endif
}

// MARK: - Keychain Errors

enum KeychainError: LocalizedError {
    case storageError(Error)
    case retrievalError(Error)
    case deletionError(Error)
    
    var errorDescription: String? {
        switch self {
        case .storageError(let error):
            return "Failed to store data in keychain: \(error.localizedDescription)"
        case .retrievalError(let error):
            return "Failed to retrieve data from keychain: \(error.localizedDescription)"
        case .deletionError(let error):
            return "Failed to delete data from keychain: \(error.localizedDescription)"
        }
    }
}
