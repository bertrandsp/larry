//
//  TopicCardViews.swift
//  larry-ios
//
//  Created by AI Assistant on 10/2/25.
//

import SwiftUI

// MARK: - User Topic Card

struct UserTopicCard: View {
    let userTopic: UserTopic
    @ObservedObject var viewModel: TopicManagementViewModel
    @State private var showingWeightSlider = false
    @State private var tempWeight: Double
    
    init(userTopic: UserTopic, viewModel: TopicManagementViewModel) {
        self.userTopic = userTopic
        self.viewModel = viewModel
        self._tempWeight = State(initialValue: Double(userTopic.weight))
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(userTopic.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text("\(userTopic.termCount) terms")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Weight Badge
                WeightBadge(weight: userTopic.weight, isEnabled: userTopic.enabled)
                
                // Toggle Button
                Button {
                    Task {
                        await viewModel.toggleTopic(userTopic)
                    }
                } label: {
                    Image(systemName: userTopic.enabled ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(userTopic.enabled ? .green : .secondary)
                }
                .disabled(viewModel.state == .loading)
            }
            
            // Weight Slider (when expanded)
            if showingWeightSlider {
                VStack(spacing: 8) {
                    HStack {
                        Text("Weight: \(Int(tempWeight))%")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Button("Done") {
                            Task {
                                await viewModel.updateTopicWeight(userTopic, newWeight: Int(tempWeight))
                                showingWeightSlider = false
                            }
                        }
                        .font(.caption)
                        .disabled(Int(tempWeight) == userTopic.weight)
                    }
                    
                    Slider(
                        value: $tempWeight,
                        in: 0...100,
                        step: 5
                    ) {
                        Text("Weight")
                    } minimumValueLabel: {
                        Text("0%")
                            .font(.caption2)
                    } maximumValueLabel: {
                        Text("100%")
                            .font(.caption2)
                    }
                    .tint(.blue)
                }
                .padding(.top, 4)
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingWeightSlider.toggle()
                    }
                } label: {
                    Label("Adjust Weight", systemImage: "slider.horizontal.3")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.state == .loading)
                
                Spacer()
                
                Button {
                    Task {
                        await viewModel.removeTopic(userTopic)
                    }
                } label: {
                    Label("Remove", systemImage: "trash")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
                .disabled(viewModel.state == .loading)
            }
        }
        .padding()
        .background(userTopic.enabled ? Color(.systemBackground) : Color(.systemGray6))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(userTopic.enabled ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .cornerRadius(12)
        .opacity(userTopic.enabled ? 1.0 : 0.7)
    }
}

// MARK: - Available Topic Card

struct AvailableTopicCard: View {
    let topic: AvailableTopic
    @ObservedObject var viewModel: TopicManagementViewModel
    @State private var isAdding = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text(topic.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if topic.isPopular {
                    PopularBadge()
                }
            }
            
            // Stats
            HStack {
                Label("\(topic.termCount)", systemImage: "book.fill")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Label("\(topic.userCount)", systemImage: "person.fill")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Add Button
            Button {
                Task {
                    isAdding = true
                    await viewModel.addTopic(topic, weight: viewModel.suggestedWeightForNewTopic())
                    isAdding = false
                }
            } label: {
                HStack {
                    if isAdding {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "plus.circle.fill")
                    }
                    Text("Add")
                }
                .font(.caption)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isAdding || viewModel.state == .loading)
        }
        .padding(12)
        .frame(width: 160, height: 120)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Views

struct WeightBadge: View {
    let weight: Int
    let isEnabled: Bool
    
    var body: some View {
        Text("\(weight)%")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(isEnabled ? .white : .secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isEnabled ? Color.blue : Color(.systemGray4))
            )
    }
}

struct PopularBadge: View {
    var body: some View {
        Text("Popular")
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.orange)
            )
    }
}

// MARK: - Preview

#Preview("User Topic Card - Enabled") {
    UserTopicCard(
        userTopic: UserTopic.previewData,
        viewModel: TopicManagementViewModel.preview()
    )
    .padding()
}

#Preview("User Topic Card - Disabled") {
    UserTopicCard(
        userTopic: UserTopic(
            id: "disabled-topic",
            topicId: "topic-id",
            name: "Disabled Topic",
            weight: 25,
            enabled: false,
            termCount: 89,
            category: "other",
            createdAt: "2024-08-15T10:30:00Z",
            updatedAt: "2024-09-20T14:45:00Z"
        ),
        viewModel: TopicManagementViewModel.preview()
    )
    .padding()
}

#Preview("Available Topic Card") {
    AvailableTopicCard(
        topic: AvailableTopic.previewData,
        viewModel: TopicManagementViewModel.preview()
    )
    .padding()
}

#Preview("Available Topic Cards") {
    ScrollView(.horizontal) {
        HStack {
            ForEach(AvailableTopic.previewDataList) { topic in
                AvailableTopicCard(
                    topic: topic,
                    viewModel: TopicManagementViewModel.preview()
                )
            }
        }
        .padding()
    }
}
