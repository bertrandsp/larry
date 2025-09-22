import SwiftUI

struct InterestsView: View {
    @EnvironmentObject private var apiService: APIService
    @State private var topics: [Topic] = []
    @State private var isLoading = false
    @State private var hasChanges = false
    @State private var errorMessage: String?
    @State private var showingSaveAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    loadingView
                } else {
                    VStack(spacing: 20) {
                        // Header
                        headerView
                        
                        // Topics list
                        topicsList
                        
                        // Save button
                        if hasChanges {
                            saveButton
                        }
                    }
                }
            }
            .navigationTitle("Interests")
            .navigationBarTitleDisplayMode(.large)
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
            .alert("Success", isPresented: $showingSaveAlert) {
                Button("OK") { }
            } message: {
                Text("Your interests have been updated!")
            }
        }
        .task {
            await loadTopics()
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Customize your learning")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Adjust the weights to focus on topics that matter most to you. Higher weights mean more vocabulary from that area.")
                .font(.body)
                .foregroundColor(.secondary)
            
            // Total weight indicator
            let totalWeight = topics.reduce(0) { $0 + $1.weight }
            HStack {
                Text("Total weight:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(Int(totalWeight * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(totalWeight == 1.0 ? .green : .orange)
                
                Spacer()
                
                if totalWeight != 1.0 {
                    Text("Must equal 100%")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .padding(.horizontal)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading your interests...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 50)
    }
    
    private var topicsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach($topics) { $topic in
                    TopicWeightCard(topic: $topic) {
                        hasChanges = true
                    }
                }
            }
            .padding()
        }
    }
    
    private var saveButton: some View {
        VStack {
            Button {
                Task {
                    await saveTopicWeights()
                }
            } label: {
                Text("Save Changes")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .disabled(isLoading)
            
            Button("Reset to Default") {
                resetToDefaults()
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
    
    private func loadTopics() async {
        isLoading = true
        errorMessage = nil
        
        do {
            topics = try await apiService.getTopics()
        } catch {
            errorMessage = error.localizedDescription
            // Load mock data for preview
            loadMockTopics()
        }
        
        isLoading = false
    }
    
    private func saveTopicWeights() async {
        isLoading = true
        
        let updates = topics.map { topic in
            TopicWeightUpdate(topicId: topic.id, weight: topic.weight)
        }
        
        do {
            _ = try await apiService.updateTopicWeights(updates)
            hasChanges = false
            showingSaveAlert = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func resetToDefaults() {
        let defaultWeight = 1.0 / Double(topics.count)
        for i in topics.indices {
            topics[i].weight = defaultWeight
        }
        hasChanges = true
    }
    
    private func loadMockTopics() {
        topics = [
            Topic(
                id: "1",
                name: "Technology",
                description: "Software development, AI, and tech trends",
                category: .career,
                iconName: "laptopcomputer",
                colorHex: "#007AFF",
                isActive: true,
                weight: 0.3,
                createdAt: Date(),
                updatedAt: Date(),
                totalTerms: 150,
                masteredTerms: 45,
                lastStudiedAt: Date()
            ),
            Topic(
                id: "2",
                name: "Travel",
                description: "Places, cultures, and travel experiences",
                category: .travel,
                iconName: "airplane",
                colorHex: "#34C759",
                isActive: true,
                weight: 0.25,
                createdAt: Date(),
                updatedAt: Date(),
                totalTerms: 200,
                masteredTerms: 80,
                lastStudiedAt: Date()
            ),
            Topic(
                id: "3",
                name: "Cooking",
                description: "Culinary techniques and food culture",
                category: .hobby,
                iconName: "fork.knife",
                colorHex: "#FF9500",
                isActive: true,
                weight: 0.2,
                createdAt: Date(),
                updatedAt: Date(),
                totalTerms: 100,
                masteredTerms: 30,
                lastStudiedAt: Date()
            ),
            Topic(
                id: "4",
                name: "Business",
                description: "Finance, marketing, and entrepreneurship",
                category: .career,
                iconName: "chart.line.uptrend.xyaxis",
                colorHex: "#FF3B30",
                isActive: true,
                weight: 0.25,
                createdAt: Date(),
                updatedAt: Date(),
                totalTerms: 120,
                masteredTerms: 25,
                lastStudiedAt: Date()
            )
        ]
    }
}

struct TopicWeightCard: View {
    @Binding var topic: Topic
    let onWeightChanged: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 12) {
                    // Icon
                    Image(systemName: topic.category.iconSystemName)
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color(hex: topic.colorHex ?? "#007AFF"))
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(topic.name)
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        if let description = topic.description {
                            Text(description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
                
                Spacer()
                
                // Weight percentage
                Text("\(Int(topic.weight * 100))%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            // Weight slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Interest Level")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Low")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("High")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Slider(value: $topic.weight, in: 0.0...1.0, step: 0.05) {
                    Text("Weight")
                } minimumValueLabel: {
                    Text("0%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } maximumValueLabel: {
                    Text("100%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } onEditingChanged: { _ in
                    onWeightChanged()
                }
                .accentColor(Color(hex: topic.colorHex ?? "#007AFF"))
            }
            
            // Statistics (if available)
            if let totalTerms = topic.totalTerms, let masteredTerms = topic.masteredTerms {
                HStack {
                    Label("\(totalTerms) terms", systemImage: "book.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Label("\(masteredTerms) mastered", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// Extension to create Color from hex string
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    InterestsView()
        .environmentObject(APIService())
}
