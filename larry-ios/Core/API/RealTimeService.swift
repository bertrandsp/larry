//
//  RealTimeService.swift
//  larry-ios
//
//  Created by AI Assistant on 9/15/25.
//

import Foundation
import Combine

/// Service for real-time updates using WebSocket or Server-Sent Events
@MainActor
class RealTimeService: ObservableObject {
    static let shared = RealTimeService()
    
    // MARK: - Published Properties
    
    @Published var isConnected = false
    @Published var lastUpdateTime: Date?
    @Published var connectionStatus: ConnectionStatus = .disconnected
    
    // MARK: - Private Properties
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession
    private var cancellables = Set<AnyCancellable>()
    private var heartbeatTimer: Timer?
    private var reconnectTimer: Timer?
    var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    private let baseURL = "ws://localhost:4001"
    
    // MARK: - Callbacks
    
    var onNewWordsAvailable: (() -> Void)?
    var onConnectionStatusChanged: ((ConnectionStatus) -> Void)?
    var onError: ((Error) -> Void)?
    
    // MARK: - Connection Status
    
    enum ConnectionStatus {
        case disconnected
        case connecting
        case connected
        case reconnecting
        case failed
    }
    
    // MARK: - Initialization
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.urlSession = URLSession(configuration: config)
        
        #if DEBUG
        print("🔌 RealTimeService initialized")
        #endif
    }
    
    deinit {
        Task { @MainActor in
            disconnect()
        }
    }
    
    // MARK: - Public Methods
    
    /// Connect once - ensures only one connection attempt
    func connectOnce() {
        guard webSocketTask == nil else { 
            #if DEBUG
            print("🔌 Already connected")
            #endif
            return 
        }
        connect()
    }
    
    func connect() {
        guard connectionStatus != .connected && connectionStatus != .connecting else {
            #if DEBUG
            print("🔌 Already connected or connecting")
            #endif
            return
        }
        
        #if DEBUG
        print("🔌 Connecting to real-time service...")
        #endif
        
        connectionStatus = .connecting
        onConnectionStatusChanged?(connectionStatus)
        
        guard let url = URL(string: "\(baseURL)/ws") else {
            handleConnectionError(RealTimeError.invalidURL)
            return
        }
        
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        
        startReceiving()
        startHeartbeat()
        
        // Set connection timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            if self?.connectionStatus == .connecting {
                self?.handleConnectionError(RealTimeError.connectionTimeout)
            }
        }
    }
    
    func disconnect() {
        #if DEBUG
        print("🔌 Disconnecting from real-time service...")
        #endif
        
        connectionStatus = .disconnected
        onConnectionStatusChanged?(connectionStatus)
        
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
        
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        
        isConnected = false
        reconnectAttempts = 0
    }
    
    func sendMessage(_ message: RealTimeMessage) {
        guard connectionStatus == .connected else {
            #if DEBUG
            print("🔌 Cannot send message - not connected")
            #endif
            return
        }
        
        do {
            let data = try JSONEncoder().encode(message)
            let message = URLSessionWebSocketTask.Message.data(data)
            
            webSocketTask?.send(message) { [weak self] error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.handleConnectionError(error)
                    }
                }
            }
            
            #if DEBUG
            print("📤 Sent real-time message: \(message)")
            #endif
            
        } catch {
            handleConnectionError(error)
        }
    }
    
    // MARK: - Private Methods
    
    private func startReceiving() {
        webSocketTask?.receive { [weak self] result in
            DispatchQueue.main.async {
                self?.handleReceiveResult(result)
            }
            
            // Continue receiving messages
            Task { @MainActor in
                if self?.connectionStatus == .connected {
                    self?.startReceiving()
                }
            }
        }
    }
    
    private func handleReceiveResult(_ result: Result<URLSessionWebSocketTask.Message, Error>) {
        switch result {
        case .success(let message):
            handleReceivedMessage(message)
        case .failure(let error):
            handleConnectionError(error)
        }
    }
    
    private func handleReceivedMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .data(let data):
            handleReceivedData(data)
        case .string(let text):
            if let data = text.data(using: .utf8) {
                handleReceivedData(data)
            }
        @unknown default:
            #if DEBUG
            print("🔌 Unknown message type received")
            #endif
        }
    }
    
    private func handleReceivedData(_ data: Data) {
        do {
            let response = try JSONDecoder().decode(RealTimeResponse.self, from: data)
            handleRealTimeResponse(response)
        } catch {
            #if DEBUG
            print("🔌 Failed to decode real-time message: \(error)")
            #endif
        }
    }
    
    private func handleRealTimeResponse(_ response: RealTimeResponse) {
        #if DEBUG
        print("📨 Received real-time message: \(response.type)")
        #endif
        
        lastUpdateTime = Date()
        
        switch response.type {
        case .connectionEstablished:
            handleConnectionEstablished()
        case .newWordsAvailable:
            handleNewWordsAvailable()
        case .heartbeat:
            handleHeartbeat()
        case .error:
            if let errorCodable = response.data["error"], 
               let errorMessage = errorCodable.value as? String {
                handleConnectionError(RealTimeError.serverError(errorMessage))
            }
        }
    }
    
    private func handleConnectionEstablished() {
        #if DEBUG
        print("✅ Real-time connection established")
        #endif
        
        connectionStatus = .connected
        isConnected = true
        reconnectAttempts = 0
        
        onConnectionStatusChanged?(connectionStatus)
        
        // Send initial subscription message
        sendMessage(RealTimeMessage(
            type: .subscribe,
            data: ["userId": AuthManager.shared.currentUser?.id ?? ""]
        ))
    }
    
    private func handleNewWordsAvailable() {
        #if DEBUG
        print("🆕 New words available notification received")
        #endif
        
        onNewWordsAvailable?()
    }
    
    private func handleHeartbeat() {
        // Heartbeat received - connection is alive
        #if DEBUG
        print("💓 Heartbeat received")
        #endif
    }
    
    private func handleConnectionError(_ error: Error) {
        #if DEBUG
        print("❌ Real-time connection error: \(error)")
        #endif
        
        connectionStatus = .failed
        isConnected = false
        onConnectionStatusChanged?(connectionStatus)
        onError?(error)
        
        // Attempt to reconnect
        attemptReconnect()
    }
    
    private func attemptReconnect() {
        guard reconnectAttempts < maxReconnectAttempts else {
            #if DEBUG
            print("❌ Max reconnect attempts reached")
            #endif
            return
        }
        
        reconnectAttempts += 1
        connectionStatus = .reconnecting
        onConnectionStatusChanged?(connectionStatus)
        
        let delay = min(pow(2.0, Double(reconnectAttempts)), 30.0) // Exponential backoff, max 30s
        
        #if DEBUG
        print("🔄 Attempting to reconnect in \(delay)s (attempt \(reconnectAttempts)/\(maxReconnectAttempts))")
        #endif
        
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.connect()
            }
        }
    }
    
    private func startHeartbeat() {
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.sendHeartbeat()
            }
        }
    }
    
    private func sendHeartbeat() {
        sendMessage(RealTimeMessage(
            type: .heartbeat,
            data: [:]
        ))
    }
}

// MARK: - Data Models

struct RealTimeMessage: Codable {
    let type: MessageType
    let data: [String: String]
    let timestamp: Date
    
    init(type: MessageType, data: [String: String] = [:]) {
        self.type = type
        self.data = data
        self.timestamp = Date()
    }
    
    enum MessageType: String, Codable {
        case subscribe = "subscribe"
        case unsubscribe = "unsubscribe"
        case heartbeat = "heartbeat"
    }
}

struct RealTimeResponse: Codable {
    let type: ResponseType
    let data: [String: AnyCodable]
    let timestamp: Date
    
    enum ResponseType: String, Codable {
        case connectionEstablished = "connection_established"
        case newWordsAvailable = "new_words_available"
        case heartbeat = "heartbeat"
        case error = "error"
    }
}

struct AnyCodable: Codable {
    let value: Any
    
    init<T>(_ value: T?) {
        self.value = value ?? ()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if container.decodeNil() {
            value = ()
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let string as String:
            try container.encode(string)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let bool as Bool:
            try container.encode(bool)
        case is Void:
            try container.encodeNil()
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable value cannot be encoded")
            throw EncodingError.invalidValue(value, context)
        }
    }
}

enum RealTimeError: Error, LocalizedError {
    case invalidURL
    case connectionTimeout
    case serverError(String)
    case encodingError
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid WebSocket URL"
        case .connectionTimeout:
            return "Connection timeout"
        case .serverError(let message):
            return "Server error: \(message)"
        case .encodingError:
            return "Failed to encode message"
        case .decodingError:
            return "Failed to decode message"
        }
    }
}
