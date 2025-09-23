//
//  NetworkError.swift
//  larry-ios
//
//  Created by AI Assistant on 9/15/25.
//

import Foundation

/// Comprehensive error handling for network operations
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case encodingError(Error)
    case httpError(Int, String?)
    case unauthorized
    case forbidden
    case notFound
    case serverError
    case networkUnavailable
    case timeout
    case cancelled
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .httpError(let code, let message):
            return "HTTP Error \(code): \(message ?? "Unknown error")"
        case .unauthorized:
            return "Unauthorized access. Please log in again."
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Server error. Please try again later."
        case .networkUnavailable:
            return "Network unavailable. Please check your connection."
        case .timeout:
            return "Request timeout. Please try again."
        case .cancelled:
            return "Request was cancelled"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .unauthorized:
            return "Your session has expired"
        case .networkUnavailable:
            return "No internet connection"
        case .serverError:
            return "Server is temporarily unavailable"
        case .timeout:
            return "The request took too long to complete"
        default:
            return nil
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .unauthorized:
            return "Please log in again to continue"
        case .networkUnavailable:
            return "Check your internet connection and try again"
        case .serverError:
            return "Please wait a moment and try again"
        case .timeout:
            return "Try again with a better connection"
        default:
            return "Please try again"
        }
    }
    
    /// Whether this error should trigger a logout
    var shouldLogout: Bool {
        switch self {
        case .unauthorized, .forbidden:
            return true
        default:
            return false
        }
    }
    
    /// Whether this error is recoverable by retrying
    var isRetryable: Bool {
        switch self {
        case .timeout, .networkUnavailable, .serverError:
            return true
        case .httpError(let code, _):
            return code >= 500 // Server errors are retryable
        default:
            return false
        }
    }
}

/// Helper to convert common errors to NetworkError
extension NetworkError {
    static func from(_ error: Error) -> NetworkError {
        if let networkError = error as? NetworkError {
            return networkError
        }
        
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .networkUnavailable
            case .timedOut:
                return .timeout
            case .cancelled:
                return .cancelled
            default:
                return .unknown(error)
            }
        }
        
        return .unknown(error)
    }
}

