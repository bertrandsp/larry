//
//  LocalCache.swift
//  larry-ios
//
//  Created by AI Assistant on 9/15/25.
//

import Foundation

/// Local cache system for storing daily words and improving app performance
struct LocalCache {
    private static let file = "cachedWords.json"
    private static let preloadedFile = "preloadedWords.json"
    
    // MARK: - Daily Words Cache
    
    /// Save daily words to local cache
    static func saveDailyWords(_ words: [DailyWord]) {
        guard !words.isEmpty else { return }
        
        do {
            let data = try JSONEncoder().encode(words)
            let url = getDocumentsURL().appendingPathComponent(file)
            try data.write(to: url)
            print("💾 Saved \(words.count) daily words to cache")
        } catch {
            print("❌ Failed to save daily words to cache: \(error)")
        }
    }
    
    /// Load daily words from local cache
    static func loadDailyWords() -> [DailyWord]? {
        do {
            let url = getDocumentsURL().appendingPathComponent(file)
            let data = try Data(contentsOf: url)
            let words = try JSONDecoder().decode([DailyWord].self, from: data)
            print("📱 Loaded \(words.count) daily words from cache")
            return words
        } catch {
            print("⚠️ No cached daily words found or failed to load: \(error)")
            return nil
        }
    }
    
    /// Clear daily words cache
    static func clearDailyWords() {
        do {
            let url = getDocumentsURL().appendingPathComponent(file)
            try FileManager.default.removeItem(at: url)
            print("🗑️ Cleared daily words cache")
        } catch {
            print("⚠️ Failed to clear daily words cache: \(error)")
        }
    }
    
    // MARK: - Preloaded Words Cache
    
    /// Save preloaded words for instant access
    static func savePreloadedWords(_ words: [DailyWord]) {
        guard !words.isEmpty else { return }
        
        do {
            let data = try JSONEncoder().encode(words)
            let url = getDocumentsURL().appendingPathComponent(preloadedFile)
            try data.write(to: url)
            print("💾 Saved \(words.count) preloaded words to cache")
        } catch {
            print("❌ Failed to save preloaded words to cache: \(error)")
        }
    }
    
    /// Load preloaded words from cache
    static func loadPreloadedWords() -> [DailyWord]? {
        do {
            let url = getDocumentsURL().appendingPathComponent(preloadedFile)
            let data = try Data(contentsOf: url)
            let words = try JSONDecoder().decode([DailyWord].self, from: data)
            print("📱 Loaded \(words.count) preloaded words from cache")
            return words
        } catch {
            print("⚠️ No preloaded words found or failed to load: \(error)")
            return nil
        }
    }
    
    /// Clear preloaded words cache
    static func clearPreloadedWords() {
        do {
            let url = getDocumentsURL().appendingPathComponent(preloadedFile)
            try FileManager.default.removeItem(at: url)
            print("🗑️ Cleared preloaded words cache")
        } catch {
            print("⚠️ Failed to clear preloaded words cache: \(error)")
        }
    }
    
    // MARK: - Cache Management
    
    /// Get cache statistics
    static func getCacheStats() -> CacheStats {
        let dailyWords = loadDailyWords()?.count ?? 0
        let preloadedWords = loadPreloadedWords()?.count ?? 0
        
        return CacheStats(
            dailyWordsCount: dailyWords,
            preloadedWordsCount: preloadedWords,
            totalCacheSize: getCacheSize()
        )
    }
    
    /// Clear all caches
    static func clearAllCaches() {
        clearDailyWords()
        clearPreloadedWords()
        print("🗑️ Cleared all caches")
    }
    
    /// Check if cache is fresh (less than 24 hours old)
    static func isCacheFresh() -> Bool {
        guard let url = getDocumentsURL().appendingPathComponent(file) as URL?,
              let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let modificationDate = attributes[.modificationDate] as? Date else {
            return false
        }
        
        let cacheAge = Date().timeIntervalSince(modificationDate)
        return cacheAge < 24 * 60 * 60 // 24 hours
    }
    
    // MARK: - Helper Methods
    
    private static func getDocumentsURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private static func getCacheSize() -> Int64 {
        let documentsURL = getDocumentsURL()
        let dailyWordsURL = documentsURL.appendingPathComponent(file)
        let preloadedWordsURL = documentsURL.appendingPathComponent(preloadedFile)
        
        var totalSize: Int64 = 0
        
        if let dailyWordsSize = try? FileManager.default.attributesOfItem(atPath: dailyWordsURL.path)[.size] as? Int64 {
            totalSize += dailyWordsSize
        }
        
        if let preloadedWordsSize = try? FileManager.default.attributesOfItem(atPath: preloadedWordsURL.path)[.size] as? Int64 {
            totalSize += preloadedWordsSize
        }
        
        return totalSize
    }
}

// MARK: - Cache Statistics

struct CacheStats {
    let dailyWordsCount: Int
    let preloadedWordsCount: Int
    let totalCacheSize: Int64
    
    var formattedCacheSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalCacheSize)
    }
}
