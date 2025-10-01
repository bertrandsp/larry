//
//  EnhancedDailyWordCard.swift
//  larry-ios
//
//  Created by AI Assistant on 10/1/25.
//

import SwiftUI

/// Enhanced daily word card with rich vocabulary features
struct EnhancedDailyWordCard: View {
    let dailyWord: FirstDailyWord
    @State private var isExpanded = false
    @State private var showingSynonyms = false
    @State private var showingAntonyms = false
    @State private var showingRelatedTerms = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with term and metadata
            headerSection
            
            // Definition and example
            definitionSection
            
            // Enhanced vocabulary features (expandable)
            if isExpanded {
                enhancedVocabularySection
            }
            
            // Action buttons
            actionButtonsSection
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(dailyWord.term)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    // Part of speech
                    if let partOfSpeech = dailyWord.partOfSpeech {
                        Text(partOfSpeech.capitalized)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .cornerRadius(6)
                    }
                    
                    // Difficulty level
                    DifficultyBadge(difficulty: dailyWord.difficultyLevel)
                    
                    // Topic tag
                    Text(dailyWord.topic)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple)
                        .cornerRadius(6)
                }
            }
            
            Spacer()
            
            // Expand/collapse button
            Button(action: {
                isExpanded.toggle()
            }) {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
    }
    
    private var definitionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(dailyWord.definition)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(isExpanded ? nil : 3)
            
            if let example = dailyWord.example, !example.isEmpty {
                Text("\"\(example)\"")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
                    .lineLimit(isExpanded ? nil : 2)
            }
            
            // Confidence score indicator
            if dailyWord.confidenceScore > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    
                    Text("High Confidence")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var enhancedVocabularySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Synonyms section
            if !dailyWord.synonyms.isEmpty {
                VocabularySection(
                    title: "Synonyms",
                    icon: "arrow.right.circle.fill",
                    color: .green,
                    items: dailyWord.synonyms,
                    isExpanded: $showingSynonyms
                )
            }
            
            // Antonyms section
            if !dailyWord.antonyms.isEmpty {
                VocabularySection(
                    title: "Antonyms",
                    icon: "arrow.left.circle.fill",
                    color: .red,
                    items: dailyWord.antonyms,
                    isExpanded: $showingAntonyms
                )
            }
            
            // Related terms section
            if !dailyWord.relatedTerms.isEmpty {
                RelatedTermsSection(
                    title: "Related Terms",
                    icon: "link.circle.fill",
                    color: .blue,
                    relatedTerms: dailyWord.relatedTerms,
                    isExpanded: $showingRelatedTerms
                )
            }
            
            // Additional info
            additionalInfoSection
        }
    }
    
    private var additionalInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let etymology = dailyWord.etymology, !etymology.isEmpty {
                InfoRow(
                    icon: "book.closed.fill",
                    title: "Etymology",
                    content: etymology,
                    color: .orange
                )
            }
            
            if let pronunciation = dailyWord.pronunciation, !pronunciation.isEmpty {
                InfoRow(
                    icon: "speaker.wave.2.fill",
                    title: "Pronunciation",
                    content: pronunciation,
                    color: .purple
                )
            }
            
            if !dailyWord.tags.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "tag.fill")
                            .foregroundColor(.gray)
                            .font(.caption)
                        
                        Text("Tags")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    
                    FlowLayout(spacing: 4) {
                        ForEach(dailyWord.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(.systemGray5))
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
    }
    
    private var actionButtonsSection: some View {
        HStack(spacing: 12) {
            ActionButton(
                title: "❤️",
                action: "Favorite",
                color: .red
            ) {
                // TODO: Implement favorite action
            }
            
            ActionButton(
                title: "✅",
                action: "Relevant",
                color: .green
            ) {
                // TODO: Implement relevant action
            }
            
            ActionButton(
                title: "❌",
                action: "Unrelated",
                color: .orange
            ) {
                // TODO: Implement unrelated action
            }
            
            Spacer()
            
            if dailyWord.isFirstWord {
                Text("First Word")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .cornerRadius(6)
            }
        }
    }
}

// MARK: - Supporting Views

private struct DifficultyBadge: View {
    let difficulty: Term.DifficultyLevel
    
    var body: some View {
        Text(difficulty.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(difficultyColor)
            .cornerRadius(6)
    }
    
    private var difficultyColor: Color {
        switch difficulty {
        case .beginner:
            return .green
        case .intermediate:
            return .yellow
        case .advanced:
            return .orange
        case .expert:
            return .red
        }
    }
}

private struct VocabularySection: View {
    let title: String
    let icon: String
    let color: Color
    let items: [String]
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                isExpanded.toggle()
            }) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.caption)
                    
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                FlowLayout(spacing: 6) {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(color.opacity(0.1))
                            .foregroundColor(color)
                            .cornerRadius(6)
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }
}

private struct RelatedTermsSection: View {
    let title: String
    let icon: String
    let color: Color
    let relatedTerms: [RelatedTerm]
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                isExpanded.toggle()
            }) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.caption)
                    
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(relatedTerms, id: \.term) { relatedTerm in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(relatedTerm.term)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(color)
                            
                            Text(relatedTerm.difference)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(color.opacity(0.05))
                        .cornerRadius(6)
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }
}

private struct InfoRow: View {
    let icon: String
    let title: String
    let content: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(content)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}

private struct ActionButton: View {
    let title: String
    let action: String
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                
                Text(action)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Flow Layout Helper

struct FlowLayout: Layout {
    let spacing: CGFloat
    
    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: result.positions[index], proposal: .unspecified)
        }
    }
}

private struct FlowResult {
    let size: CGSize
    let positions: [CGPoint]
    
    init(in maxWidth: CGFloat, subviews: LayoutSubviews, spacing: CGFloat) {
        var currentPosition = CGPoint.zero
        var lineHeight: CGFloat = 0
        var positions: [CGPoint] = []
        var maxX: CGFloat = 0
        
        for subview in subviews {
            let subviewSize = subview.sizeThatFits(.unspecified)
            
            if currentPosition.x + subviewSize.width > maxWidth && currentPosition.x > 0 {
                // Move to next line
                currentPosition.x = 0
                currentPosition.y += lineHeight + spacing
                lineHeight = 0
            }
            
            positions.append(currentPosition)
            lineHeight = max(lineHeight, subviewSize.height)
            currentPosition.x += subviewSize.width + spacing
            maxX = max(maxX, currentPosition.x - spacing)
        }
        
        self.positions = positions
        self.size = CGSize(width: maxX, height: currentPosition.y + lineHeight)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            EnhancedDailyWordCard(dailyWord: FirstDailyWord.previewData)
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
