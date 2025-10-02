//
//  TopicManagementView.swift
//  larry-ios
//
//  Created by AI Assistant on 10/2/25.
//

import SwiftUI

/// Main view for managing user topics and interests
struct TopicManagementView: View {
    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var viewModel: TopicManagementViewModel
    @State private var showingAddTopicSheet = false
    @State private var showingAutoBalanceAlert = false
    
    init() {
        // Initialize with the current user ID from AuthManager
        let userId = AuthManager.shared.currentUser?.id ?? "default-user"
        
        #if DEBUG
        print("🔍 TopicManagementView: AuthManager.shared.currentUser?.id = \(AuthManager.shared.currentUser?.id ?? "nil")")
        print("🔍 TopicManagementView: Using userId = \(userId)")
        #endif
        
        self._viewModel = StateObject(wrappedValue: TopicManagementViewModel(userId: userId))
    }
    
    var body: some View {
        NavigationView {
            Group {
                switch viewModel.state {
                case .idle:
                    EmptyView()
                case .loading:
                    TopicLoadingView()
                case .loaded:
                    if viewModel.userTopics.isEmpty && viewModel.availableTopics.isEmpty {
                        EmptyTopicsView()
                    } else {
                        LoadedContentView(
                            viewModel: viewModel,
                            showingAddTopicSheet: $showingAddTopicSheet,
                            showingAutoBalanceAlert: $showingAutoBalanceAlert
                        )
                    }
                case .error(let message):
                    ErrorView(message: message) {
                        Task {
                            await viewModel.refresh()
                        }
                    }
                }
            }
            .navigationTitle("Interests & Topics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Topic") {
                        showingAddTopicSheet = true
                    }
                    .disabled(viewModel.state == .loading)
                }
            }
            .sheet(isPresented: $showingAddTopicSheet) {
                AddTopicSheet(viewModel: viewModel)
            }
            .alert("Auto-Balance Weights", isPresented: $showingAutoBalanceAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Balance") {
                    Task {
                        await viewModel.autoBalanceWeights()
                    }
                }
            } message: {
                Text("This will automatically distribute weights evenly across all enabled topics to total 100%.")
            }
            .task {
                #if DEBUG
                print("🔍 TopicManagementView: .task modifier executing - calling loadTopics()")
                #endif
                await viewModel.loadTopics()
            }
        }
    }
}

// MARK: - Supporting Views

private struct TopicLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading your topics...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Something went wrong")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct LoadedContentView: View {
    @ObservedObject var viewModel: TopicManagementViewModel
    @Binding var showingAddTopicSheet: Bool
    @Binding var showingAutoBalanceAlert: Bool
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Weight Summary Card
                WeightSummaryCard(
                    viewModel: viewModel,
                    showingAutoBalanceAlert: $showingAutoBalanceAlert
                )
                
                // User Topics Section
                if !viewModel.userTopics.isEmpty {
                    UserTopicsSection(viewModel: viewModel)
                }
                
                // Available Topics Section
                if !viewModel.availableTopics.isEmpty {
                    AvailableTopicsSection(
                        viewModel: viewModel,
                        showingAddTopicSheet: $showingAddTopicSheet
                    )
                }
                
                // Empty State
                if viewModel.userTopics.isEmpty && viewModel.availableTopics.isEmpty {
                    EmptyTopicsView()
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}

private struct WeightSummaryCard: View {
    @ObservedObject var viewModel: TopicManagementViewModel
    @Binding var showingAutoBalanceAlert: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Weight")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(viewModel.totalWeight)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(viewModel.isWeightBalanced ? .green : .orange)
                        
                        Text("%")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(viewModel.isWeightBalanced ? .green : .orange)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(viewModel.enabledTopicsCount) enabled")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if viewModel.disabledTopicsCount > 0 {
                        Text("\(viewModel.disabledTopicsCount) disabled")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Progress Bar
            ProgressView(value: Double(viewModel.totalWeight), total: 100.0)
                .progressViewStyle(LinearProgressViewStyle(tint: viewModel.isWeightBalanced ? .green : .orange))
                .scaleEffect(y: 2.0)
            
            // Auto-balance button
            if !viewModel.isWeightBalanced && viewModel.enabledTopicsCount > 1 {
                Button("Auto-Balance Weights") {
                    showingAutoBalanceAlert = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

private struct UserTopicsSection: View {
    @ObservedObject var viewModel: TopicManagementViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Topics")
                .font(.headline)
                .padding(.horizontal, 4)
            
            LazyVStack(spacing: 8) {
                ForEach(viewModel.topicsByWeight) { userTopic in
                    UserTopicCard(userTopic: userTopic, viewModel: viewModel)
                }
            }
        }
    }
}

private struct AvailableTopicsSection: View {
    @ObservedObject var viewModel: TopicManagementViewModel
    @Binding var showingAddTopicSheet: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Available Topics")
                    .font(.headline)
                
                Spacer()
                
                Button("Browse All") {
                    showingAddTopicSheet = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(Array(viewModel.popularAvailableTopics.prefix(5))) { topic in
                        AvailableTopicCard(topic: topic, viewModel: viewModel)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

private struct EmptyTopicsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Topics Yet")
                .font(.headline)
            
            Text("Add some topics to personalize your vocabulary learning experience.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview("Loaded State") {
    TopicManagementView()
        .environmentObject(TopicManagementViewModel.preview())
}

#Preview("Loading State") {
    TopicManagementView()
        .environmentObject(TopicManagementViewModel.previewLoading())
}

#Preview("Error State") {
    TopicManagementView()
        .environmentObject(TopicManagementViewModel.previewError())
}
