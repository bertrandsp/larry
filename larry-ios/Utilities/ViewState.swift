//
//  ViewState.swift
//  larry-ios
//
//  Created by AI Assistant on 9/15/25.
//

import Foundation

/// Generic view state for handling loading, success, and error states
enum ViewState<T> {
    case idle
    case loading
    case success(T)
    case error(Error)
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
    
    var data: T? {
        if case .success(let data) = self {
            return data
        }
        return nil
    }
    
    var error: Error? {
        if case .error(let error) = self {
            return error
        }
        return nil
    }
    
    var hasError: Bool {
        if case .error = self {
            return true
        }
        return false
    }
    
    var hasData: Bool {
        if case .success = self {
            return true
        }
        return false
    }
}

/// Convenience extensions for common operations
extension ViewState {
    mutating func setLoading() {
        self = .loading
    }
    
    mutating func setSuccess(_ data: T) {
        self = .success(data)
    }
    
    mutating func setError(_ error: Error) {
        self = .error(error)
    }
    
    mutating func setIdle() {
        self = .idle
    }
}

/// For views that need to handle empty states
enum LoadableViewState<T> {
    case idle
    case loading
    case success(T)
    case empty
    case error(Error)
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
    
    var data: T? {
        if case .success(let data) = self {
            return data
        }
        return nil
    }
    
    var error: Error? {
        if case .error(let error) = self {
            return error
        }
        return nil
    }
    
    var hasError: Bool {
        if case .error = self {
            return true
        }
        return false
    }
    
    var hasData: Bool {
        if case .success = self {
            return true
        }
        return false
    }
    
    var isEmpty: Bool {
        if case .empty = self {
            return true
        }
        return false
    }
}

extension LoadableViewState {
    mutating func setLoading() {
        self = .loading
    }
    
    mutating func setSuccess(_ data: T) {
        self = .success(data)
    }
    
    mutating func setEmpty() {
        self = .empty
    }
    
    mutating func setError(_ error: Error) {
        self = .error(error)
    }
    
    mutating func setIdle() {
        self = .idle
    }
}

