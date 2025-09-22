import Foundation
import Alamofire
import Combine

/// Main API service for communicating with the Larry backend
@MainActor
final class APIService: ObservableObject {
    
    // MARK: - Properties
    
    private let session: Session
    private let keychainService: KeychainService
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    @Published var isLoading = false
    @Published var lastError: APIError?
    
    // MARK: - Configuration
    
    private struct Configuration {
        #if DEBUG
        static let baseURL = "http://localhost:4000"
        #else
        static let baseURL = "https://api.larry.app" // Replace with your production URL
        #endif
        
        static let timeoutInterval: TimeInterval = 30
        static let retryLimit = 3
    }
    
    // MARK: - Initialization
    
    init() {
        self.keychainService = KeychainService()
        
        // Configure JSON decoder with date formatting
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        
        // Configure JSON encoder
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        
        // Configure Alamofire session
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Configuration.timeoutInterval
        configuration.timeoutIntervalForResource = Configuration.timeoutInterval
        
        self.session = Session(
            configuration: configuration,
            interceptor: AuthenticationInterceptor(keychainService: keychainService)
        )
        
        print("🌐 APIService initialized with base URL: \(Configuration.baseURL)")
    }
    
    // MARK: - Generic Request Method
    
    private func request<T: Codable>(
        _ endpoint: APIEndpoint,
        responseType: T.Type,
        retryCount: Int = 0
    ) async throws -> T {
        
        await MainActor.run {
            isLoading = true
            lastError = nil
        }
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        let url = "\(Configuration.baseURL)\(endpoint.path)"
        
        do {
            let response = try await session.request(
                url,
                method: endpoint.method,
                parameters: endpoint.parameters,
                encoding: endpoint.encoding,
                headers: endpoint.headers
            )
            .validate()
            .serializingDecodable(T.self, decoder: decoder)
            .value
            
            print("✅ API Request successful: \(endpoint.method.rawValue) \(endpoint.path)")
            return response
            
        } catch {
            print("❌ API Request failed: \(endpoint.method.rawValue) \(endpoint.path)")
            print("   Error: \(error)")
            
            let apiError = APIError.from(error)
            
            // Retry logic for network errors
            if case .networkError = apiError, retryCount < Configuration.retryLimit {
                print("🔄 Retrying request (\(retryCount + 1)/\(Configuration.retryLimit))")
                try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(retryCount)) * 1_000_000_000))
                return try await request(endpoint, responseType: responseType, retryCount: retryCount + 1)
            }
            
            await MainActor.run {
                lastError = apiError
            }
            
            throw apiError
        }
    }
    
    // MARK: - Health Check
    
    func healthCheck() async throws -> HealthResponse {
        let endpoint = APIEndpoint.health
        return try await request(endpoint, responseType: HealthResponse.self)
    }
    
    // MARK: - Authentication
    
    func signInWithApple(identityToken: String, authorizationCode: String) async throws -> AuthResponse {
        let endpoint = APIEndpoint.signInWithApple(
            identityToken: identityToken,
            authorizationCode: authorizationCode
        )
        return try await request(endpoint, responseType: AuthResponse.self)
    }
    
    func startGoogleSignIn() async throws -> GoogleSignInResponse {
        let endpoint = APIEndpoint.startGoogleSignIn
        return try await request(endpoint, responseType: GoogleSignInResponse.self)
    }
    
    func refreshTokens() async throws -> TokenRefreshResponse {
        guard let refreshToken = keychainService.getRefreshToken() else {
            throw APIError.authenticationRequired
        }
        
        let endpoint = APIEndpoint.refreshToken(refreshToken: refreshToken)
        return try await request(endpoint, responseType: TokenRefreshResponse.self)
    }
    
    func getUserProfile() async throws -> User {
        let endpoint = APIEndpoint.getUserProfile
        return try await request(endpoint, responseType: User.self)
    }
    
    // MARK: - Daily Words
    
    func getDailyWords() async throws -> DailyWordResponse {
        let endpoint = APIEndpoint.getDailyWords
        return try await request(endpoint, responseType: DailyWordResponse.self)
    }
    
    func performDailyWordAction(action: UserAction, dailyWordId: String) async throws -> DailyWord {
        let request = DailyWordActionRequest(action: action, dailyWordId: dailyWordId)
        let endpoint = APIEndpoint.dailyWordAction(request: request)
        return try await request(endpoint, responseType: DailyWord.self)
    }
    
    // MARK: - Topics
    
    func getTopics() async throws -> [Topic] {
        let endpoint = APIEndpoint.getTopics
        return try await request(endpoint, responseType: [Topic].self)
    }
    
    func updateTopicWeights(_ updates: [TopicWeightUpdate]) async throws -> TopicWeightResponse {
        let endpoint = APIEndpoint.updateTopicWeights(updates: updates)
        return try await request(endpoint, responseType: TopicWeightResponse.self)
    }
    
    // MARK: - Learning Stats
    
    func getLearningStats() async throws -> LearningStats {
        let endpoint = APIEndpoint.getLearningStats
        return try await request(endpoint, responseType: LearningStats.self)
    }
}

// MARK: - API Endpoints

private enum APIEndpoint {
    case health
    case signInWithApple(identityToken: String, authorizationCode: String)
    case startGoogleSignIn
    case refreshToken(refreshToken: String)
    case getUserProfile
    case getDailyWords
    case dailyWordAction(request: DailyWordActionRequest)
    case getTopics
    case updateTopicWeights(updates: [TopicWeightUpdate])
    case getLearningStats
    
    var path: String {
        switch self {
        case .health:
            return "/health"
        case .signInWithApple:
            return "/auth-direct/apple"
        case .startGoogleSignIn:
            return "/auth-direct/google/start"
        case .refreshToken:
            return "/auth-direct/refresh"
        case .getUserProfile:
            return "/auth-direct/profile"
        case .getDailyWords:
            return "/daily"
        case .dailyWordAction:
            return "/actions/daily-word"
        case .getTopics:
            return "/topics"
        case .updateTopicWeights:
            return "/topics/weights"
        case .getLearningStats:
            return "/stats"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .health, .getUserProfile, .getDailyWords, .getTopics, .getLearningStats:
            return .get
        case .signInWithApple, .startGoogleSignIn, .refreshToken, .dailyWordAction, .updateTopicWeights:
            return .post
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .signInWithApple(let identityToken, let authorizationCode):
            return [
                "identity_token": identityToken,
                "authorization_code": authorizationCode
            ]
        case .refreshToken(let refreshToken):
            return ["refresh_token": refreshToken]
        case .dailyWordAction(let request):
            return try? request.asDictionary()
        case .updateTopicWeights(let updates):
            return ["updates": updates.map { try? $0.asDictionary() }]
        default:
            return nil
        }
    }
    
    var encoding: ParameterEncoding {
        switch method {
        case .get:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
    
    var headers: HTTPHeaders? {
        var headers = HTTPHeaders()
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        return headers
    }
}

// MARK: - Authentication Interceptor

private class AuthenticationInterceptor: RequestInterceptor {
    private let keychainService: KeychainService
    
    init(keychainService: KeychainService) {
        self.keychainService = keychainService
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        
        // Add authorization header if we have an access token
        if let accessToken = keychainService.getAccessToken() {
            urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        // Handle token refresh for 401 errors
        if let response = request.task?.response as? HTTPURLResponse,
           response.statusCode == 401,
           keychainService.getRefreshToken() != nil {
            completion(.retryWithDelay(1.0))
        } else {
            completion(.doNotRetry)
        }
    }
}

// MARK: - Supporting Models

struct HealthResponse: Codable {
    let status: String
    let timestamp: Date
    let version: String?
}

struct GoogleSignInResponse: Codable {
    let authUrl: String
    let state: String
    
    enum CodingKeys: String, CodingKey {
        case authUrl = "auth_url"
        case state
    }
}

// MARK: - API Errors

enum APIError: LocalizedError, Equatable {
    case networkError
    case authenticationRequired
    case invalidResponse
    case serverError(Int)
    case decodingError
    case unknown(String)
    
    static func from(_ error: Error) -> APIError {
        if let afError = error as? AFError {
            switch afError {
            case .responseValidationFailed(let reason):
                if case .unacceptableStatusCode(let code) = reason {
                    if code == 401 {
                        return .authenticationRequired
                    } else {
                        return .serverError(code)
                    }
                }
                return .invalidResponse
            case .responseSerializationFailed:
                return .decodingError
            default:
                return .networkError
            }
        }
        return .unknown(error.localizedDescription)
    }
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network connection error. Please check your internet connection."
        case .authenticationRequired:
            return "Authentication required. Please sign in again."
        case .invalidResponse:
            return "Invalid response from server."
        case .serverError(let code):
            return "Server error (\(code)). Please try again later."
        case .decodingError:
            return "Failed to process server response."
        case .unknown(let message):
            return message
        }
    }
}

// MARK: - Extensions

private extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}
