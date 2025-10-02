//
//  AddTopicSheet.swift
//  larry-ios
//
//  Created by AI Assistant on 10/2/25.
//

import SwiftUI

struct AddTopicSheet: View {
    @ObservedObject var viewModel: TopicManagementViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var selectedCategory: String = "all"
    @State private var sortBy: SortOption = .popularity
    
    enum SortOption: String, CaseIterable {
        case popularity = "Popularity"
        case name = "Name"
        case termCount = "Term Count"
        
        var systemImage: String {
            switch self {
            case .popularity: return "heart.fill"
            case .name: return "textformat.abc"
            case .termCount: return "book.fill"
            }
        }
    }
    
    var filteredTopics: [AvailableTopic] {
        var topics = viewModel.availableTopics
        
        // Filter by search text
        if !searchText.isEmpty {
            topics = topics.filter { topic in
                topic.name.localizedCaseInsensitiveContains(searchText) ||
                (topic.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Filter by category
        if selectedCategory != "all" {
            topics = topics.filter { $0.category == selectedCategory }
        }
        
        // Sort
        switch sortBy {
        case .popularity:
            topics = topics.sorted { first, second in
                if first.isPopular != second.isPopular {
                    return first.isPopular && !second.isPopular
                }
                return first.userCount > second.userCount
            }
        case .name:
            topics = topics.sorted { $0.name < $1.name }
        case .termCount:
            topics = topics.sorted { $0.termCount > $1.termCount }
        }
        
        return topics
    }
    
    var availableCategories: [String] {
        let categories = Set(viewModel.availableTopics.compactMap { $0.category })
        return ["all"] + categories.sorted()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filters
                VStack(spacing: 12) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search topics...", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Filter Controls
                    HStack {
                        // Category Filter
                        Menu {
                            ForEach(availableCategories, id: \.self) { category in
                                Button {
                                    selectedCategory = category
                                } label: {
                                    HStack {
                                        Text(category.capitalized)
                                        if selectedCategory == category {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                Text(selectedCategory.capitalized)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        Spacer()
                        
                        // Sort Menu
                        Menu {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button {
                                    sortBy = option
                                } label: {
                                    HStack {
                                        Image(systemName: option.systemImage)
                                        Text(option.rawValue)
                                        if sortBy == option {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: sortBy.systemImage)
                                Text("Sort")
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                
                // Topics List
                if filteredTopics.isEmpty {
                    EmptySearchView(searchText: searchText)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredTopics) { topic in
                                AddTopicRow(topic: topic, viewModel: viewModel)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Add Topics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .task {
            if viewModel.availableTopics.isEmpty {
                try? await viewModel.loadAvailableTopics()
            }
        }
    }
}

// MARK: - Supporting Views

private struct AddTopicRow: View {
    let topic: AvailableTopic
    @ObservedObject var viewModel: TopicManagementViewModel
    @State private var isAdding = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Topic Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(topic.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if topic.isPopular {
                        PopularBadge()
                    }
                }
                
                if let description = topic.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Label("\(topic.termCount) terms", systemImage: "book.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Label("\(topic.userCount) users", systemImage: "person.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Add Button
            Button {
                Task {
                    isAdding = true
                    await viewModel.addTopic(topic, weight: viewModel.suggestedWeightForNewTopic())
                    isAdding = false
                }
            } label: {
                Group {
                    if isAdding {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .foregroundColor(.blue)
            .disabled(isAdding || viewModel.state == .loading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

private struct EmptySearchView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Topics Found")
                .font(.headline)
            
            if searchText.isEmpty {
                Text("No topics are available to add.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("No topics match '\(searchText)'. Try a different search term or category.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    AddTopicSheet(viewModel: TopicManagementViewModel.preview())
}
