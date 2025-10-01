//
//  APIService.swift
//  larry-ios
//
//  Created by AI Assistant on 9/15/25.
//

import Foundation
// import Alamofire // TODO: Add Alamofire dependency to Xcode project
import Combine

/// Main API service for communicating with the Larry backend
@MainActor
class APIService: ObservableObject {
    static let shared = APIService()
    
    // MARK: - Properties
    
    private let session: URLSession
    private let baseURL: URL
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Configuration
    
    private struct Config {
        #if DEBUG
        static let baseURLString = Self.getDebugBaseURL()
        #else
        static let baseURLString = "https://api.larry.app" // TODO: Replace with production URL
        #endif
        
        static let timeoutInterval: TimeInterval = 30.0
        
        #if DEBUG
        private static func getDebugBaseURL() -> String {
            // Check for environment variable or use default
            if let envURL = ProcessInfo.processInfo.environment["LARRY_API_URL"] {
                return envURL
            }
            
            // Default to network IP for iOS Simulator compatibility
            // Change this to "localhost" if testing on physical device via USB
            return "http://192.168.1.101:4001"
        }
        #endif
    }
    
    // MARK: - Initialization
    
    private init() {
        guard let url = URL(string: Config.baseURLString) else {
            fatalError("Invalid base URL: \(Config.baseURLString)")
        }
        
        self.baseURL = url
        
        // Configure URLSession
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Config.timeoutInterval
        configuration.timeoutIntervalForResource = Config.timeoutInterval
        
        self.session = URLSession(configuration: configuration)
        
        #if DEBUG
        print("🌐 APIService initialized with base URL: \(baseURL)")
        #endif
    }
    
    // MARK: - Generic Request Method
    
    /// Generic method to send API requests
    func send<T: Decodable>(
        _ request: APIRequest,
        responseType: T.Type
    ) async throws -> T {
        let url = baseURL.appendingPathComponent(request.path)
        
        #if DEBUG
        print("🚀 ===== API REQUEST STARTED =====")
        print("🚀 Method: \(request.method.rawValue)")
        print("🚀 URL: \(url)")
        print("🚀 Base URL: \(baseURL)")
        print("🚀 Path: \(request.path)")
        if let body = request.body {
            print("🚀 Request Body: \(String(data: body, encoding: .utf8) ?? "Unable to decode")")
        }
        if let headers = request.headers {
            print("🚀 Headers: \(headers)")
        }
        #endif
        
        do {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = request.method.rawValue
            urlRequest.httpBody = request.body
            
            // Add headers
            if let headers = request.headers {
                for (key, value) in headers {
                    urlRequest.setValue(value, forHTTPHeaderField: key)
                }
            }
            
            // Add authorization header if token exists
            if let token = AuthManager.shared.accessToken {
                urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            #if DEBUG
            print("🚀 Sending request...")
            #endif
            
            let (data, urlResponse) = try await session.data(for: urlRequest)
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                #if DEBUG
                print("🚀 ❌ Invalid response type")
                #endif
                throw NetworkError.unknown(URLError(.badServerResponse))
            }
            
            #if DEBUG
            print("🚀 ✅ API Response received:")
            print("🚀   - Status Code: \(httpResponse.statusCode)")
            print("🚀   - Response Headers: \(httpResponse.allHeaderFields)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("🚀   - Response Body: \(responseString)")
            }
            #endif
            
            // Handle HTTP errors
            switch httpResponse.statusCode {
            case 200...299:
                break
            case 401:
                // Try to refresh token and retry once
                try await handleUnauthorizedError()
                throw NetworkError.unauthorized
            case 403:
                throw NetworkError.forbidden
            case 404:
                throw NetworkError.notFound
            case 500...599:
                throw NetworkError.serverError
            default:
                throw NetworkError.httpError(httpResponse.statusCode, HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
            }
            
            // Decode response
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let response = try decoder.decode(T.self, from: data)
            return response
            
        } catch let decodingError as DecodingError {
            #if DEBUG
            print("🚀 ❌ ===== DECODING ERROR =====")
            print("🚀 Decoding Error: \(decodingError)")
            #endif
            throw NetworkError.decodingError(decodingError)
        } catch let networkError as NetworkError {
            #if DEBUG
            print("🚀 ❌ ===== NETWORK ERROR =====")
            print("🚀 Network Error: \(networkError)")
            #endif
            throw networkError
        } catch {
            #if DEBUG
            print("🚀 ❌ ===== UNKNOWN API ERROR =====")
            print("🚀 Error type: \(type(of: error))")
            print("🚀 Error description: \(error.localizedDescription)")
            print("🚀 Full error: \(error)")
            #endif
            throw NetworkError.from(error)
        }
    }
    
    /// Send request without expecting a response body
    func send(_ request: APIRequest) async throws {
        let _: EmptyResponse = try await send(request, responseType: EmptyResponse.self)
    }
    
    // MARK: - First Daily Word & Delivery Tracking
    
    /// Get the first daily word for users who just completed onboarding
    func getFirstDailyWord(userId: String) async throws -> EnhancedFirstDailyWordResponse {
        let request = APIRequest(
            method: .GET,
            path: "/first-daily?userId=\(userId)"
        )
        
        return try await send(request, responseType: EnhancedFirstDailyWordResponse.self)
    }
    
    /// Track user action on a delivered word
    func trackDeliveryAction(deliveryId: String, action: DeliveryAction, wordbankId: String? = nil) async throws -> DeliveryActionResponse {
        let requestBody = DeliveryActionRequest(
            deliveryId: deliveryId,
            action: action,
            wordbankId: wordbankId
        )
        
        let request = try APIRequest(
            method: .POST,
            path: "/first-daily/action",
            body: requestBody
        )
        
        return try await send(request, responseType: DeliveryActionResponse.self)
    }
    
    /// Get enhanced daily word (with delivery tracking) for returning users
    func getEnhancedDailyWord(userId: String) async throws -> EnhancedDailyWordResponse {
        let request = APIRequest(
            method: .GET,
            path: "/daily?userId=\(userId)"
        )
        
        return try await send(request, responseType: EnhancedDailyWordResponse.self)
    }

    // MARK: - Onboarding

    func postOnboardingStep<T: Encodable>(_ body: T, path: String) async throws {
        let request = try APIRequest(
            method: .POST,
            path: path,
            body: body
        )
        try await send(request)
    }

    func getTopics() async throws -> [Topic] {
        let request = APIRequest(method: .GET, path: "/topics")
        let response: TopicsResponse = try await send(request, responseType: TopicsResponse.self)
        // Convert OnboardingTopic to Topic for backward compatibility
        return response.topics.map { onboardingTopic in
            Topic(
                id: onboardingTopic.id,
                name: onboardingTopic.name,
                description: "\(onboardingTopic.name) vocabulary and terminology",
                category: .other,
                iconName: nil,
                colorHex: nil,
                isActive: true,
                termCount: 0,
                createdAt: Date(),
                updatedAt: Date(),
                userTopicWeight: nil
            )
        }
    }
    
    func getOnboardingTopics() async throws -> [OnboardingTopic] {
        let request = APIRequest(method: .GET, path: "/topics")
        let response: TopicsResponse = try await send(request, responseType: TopicsResponse.self)
        return response.topics
    }
    
    // MARK: - Enhanced Vocabulary Actions
    
    /// Mark a term as relevant or unrelated
    func updateTermRelevance(userId: String, termId: String, isRelevant: Bool) async throws -> VocabularyActionResponse {
        let requestBody = [
            "related": isRelevant
        ]
        
        let request = try APIRequest(
            method: .PUT,
            path: "/user/\(userId)/terms/\(termId)/relevance",
            body: requestBody
        )
        
        return try await send(request, responseType: VocabularyActionResponse.self)
    }
    
    /// Track user action on a vocabulary term
    func trackVocabularyAction(termId: String, action: VocabularyAction) async throws -> VocabularyActionResponse {
        let requestBody = [
            "action": action.rawValue,
            "termId": termId
        ]
        
        let request = try APIRequest(
            method: .POST,
            path: "/vocabulary/action",
            body: requestBody
        )
        
        return try await send(request, responseType: VocabularyActionResponse.self)
    }
}


// MARK: - API Request Structure

struct APIRequest {
    let method: HTTPMethod
    let path: String
    let body: Data?
    let headers: [String: String]?
    
    enum HTTPMethod: String, CaseIterable {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
        case PATCH = "PATCH"
    }
    
    init(
        method: HTTPMethod,
        path: String,
        body: Data? = nil,
        headers: [String: String]? = nil
    ) {
        self.method = method
        self.path = path
        self.body = body
        self.headers = headers
    }
    
    /// Convenience initializer for JSON body
    init<T: Encodable>(
        method: HTTPMethod,
        path: String,
        body: T,
        headers: [String: String]? = nil
    ) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        self.method = method
        self.path = path
        self.body = try encoder.encode(body)
        
        var finalHeaders = headers ?? [:]
        finalHeaders["Content-Type"] = "application/json"
        self.headers = finalHeaders
    }
}

// MARK: - Token Refresh Helper

private extension APIService {
    /// Handle 401 errors by attempting token refresh
    func handleUnauthorizedError() async throws {
        do {
            try await AuthManager.shared.refreshToken()
        } catch {
            await AuthManager.shared.logout()
            throw error
        }
    }
}

// MARK: - Response Models

private struct EmptyResponse: Codable {}

