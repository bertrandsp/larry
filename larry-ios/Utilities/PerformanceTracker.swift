//
//  PerformanceTracker.swift
//  larry-ios
//
//  Created by AI Assistant on 9/15/25.
//

import Foundation
import os.log

/// Performance tracking utility for measuring app performance metrics
@MainActor
class PerformanceTracker: ObservableObject {
    static let shared = PerformanceTracker()
    
    private let logger = Logger(subsystem: "com.larry.ios", category: "Performance")
    private var startTimes: [String: Date] = [:]
    
    private init() {}
    
    // MARK: - Timing Methods
    
    /// Start timing a performance metric
    func startTiming(_ metric: String) {
        startTimes[metric] = Date()
        logger.debug("Started timing: \(metric)")
    }
    
    /// End timing and log the duration
    func endTiming(_ metric: String) -> TimeInterval? {
        guard let startTime = startTimes.removeValue(forKey: metric) else {
            logger.warning("No start time found for metric: \(metric)")
            return nil
        }
        
        let duration = Date().timeIntervalSince(startTime)
        let durationMs = duration * 1000
        
        logger.info("\(metric): \(String(format: "%.2f", durationMs))ms")
        
        // Log to analytics if available
        logAnalytics(metric: metric, value: durationMs)
        
        return duration
    }
    
    /// Measure the execution time of a block
    func measure<T>(_ metric: String, block: () throws -> T) rethrows -> T {
        startTiming(metric)
        defer { _ = endTiming(metric) }
        return try block()
    }
    
    /// Measure the execution time of an async block
    func measureAsync<T>(_ metric: String, block: () async throws -> T) async rethrows -> T {
        startTiming(metric)
        defer { _ = endTiming(metric) }
        return try await block()
    }
    
    // MARK: - Specific Metrics
    
    /// Track daily word card render time
    func trackCardRenderTime(_ duration: TimeInterval) {
        let durationMs = duration * 1000
        logger.info("Daily card render time: \(String(format: "%.2f", durationMs))ms")
        logAnalytics(metric: "card_render_time_ms", value: durationMs)
    }
    
    /// Track API response time
    func trackAPIResponseTime(_ endpoint: String, duration: TimeInterval) {
        let durationMs = duration * 1000
        logger.info("API \(endpoint) response time: \(String(format: "%.2f", durationMs))ms")
        logAnalytics(metric: "api_response_time_ms", value: durationMs, properties: ["endpoint": endpoint])
    }
    
    /// Track cache hit/miss
    func trackCacheHit(_ hit: Bool, cacheType: String) {
        logger.info("Cache \(hit ? "hit" : "miss") for \(cacheType)")
        logAnalytics(metric: "cache_\(hit ? "hit" : "miss")", properties: ["cache_type": cacheType])
    }
    
    /// Track preload performance
    func trackPreloadPerformance(wordCount: Int, duration: TimeInterval) {
        let durationMs = duration * 1000
        let wordsPerSecond = Double(wordCount) / duration
        logger.info("Preloaded \(wordCount) words in \(String(format: "%.2f", durationMs))ms (\(String(format: "%.1f", wordsPerSecond)) words/sec)")
        logAnalytics(metric: "preload_performance", value: durationMs, properties: [
            "word_count": wordCount,
            "words_per_second": wordsPerSecond
        ])
    }
    
    // MARK: - Analytics Integration
    
    private func logAnalytics(metric: String, value: Double, properties: [String: Any] = [:]) {
        // TODO: Integrate with your analytics service (Firebase, Mixpanel, etc.)
        #if DEBUG
        print("📊 Analytics: \(metric) = \(value) \(properties.isEmpty ? "" : "\(properties)")")
        #endif
    }
    
    private func logAnalytics(metric: String, properties: [String: Any] = [:]) {
        // TODO: Integrate with your analytics service
        #if DEBUG
        print("📊 Analytics: \(metric) \(properties.isEmpty ? "" : "\(properties)")")
        #endif
    }
}

// MARK: - Performance Metrics

extension PerformanceTracker {
    enum Metric: String, CaseIterable {
        case appLaunch = "app_launch"
        case dailyWordLoad = "daily_word_load"
        case cardRender = "card_render"
        case cacheLoad = "cache_load"
        case preloadWords = "preload_words"
        case apiRequest = "api_request"
        case backgroundRefresh = "background_refresh"
    }
}

// MARK: - Convenience Extensions

extension PerformanceTracker {
    /// Track app launch performance
    func trackAppLaunch() {
        startTiming(Metric.appLaunch.rawValue)
    }
    
    /// Track daily word loading
    func trackDailyWordLoad() {
        startTiming(Metric.dailyWordLoad.rawValue)
    }
    
    /// Track card rendering
    func trackCardRender() {
        startTiming(Metric.cardRender.rawValue)
    }
    
    /// Track cache loading
    func trackCacheLoad() {
        startTiming(Metric.cacheLoad.rawValue)
    }
    
    /// Track word preloading
    func trackPreloadWords() {
        startTiming(Metric.preloadWords.rawValue)
    }
    
    /// Track API requests
    func trackAPIRequest() {
        startTiming(Metric.apiRequest.rawValue)
    }
    
    /// Track background refresh
    func trackBackgroundRefresh() {
        startTiming(Metric.backgroundRefresh.rawValue)
    }
}
