import SwiftUI
import AVFoundation

struct VocabularyCardView: View {
    let card: VocabularyCard
    let cardHeight: CGFloat
    let isActive: Bool
    
    @State private var isFavorited: Bool = false
    @State private var isLearned: Bool = false
    @State private var showingActions: Bool = false
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 0)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            if let imageUrl = card.imageUrl {
                // Card with image
                cardWithImage(imageUrl: imageUrl)
            } else {
                // Card without image
                cardWithoutImage()
            }
        }
        .frame(height: cardHeight)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(card.term), \(card.partOfSpeech), \(card.definition)")
        .accessibilityHint("Swipe up for next word, swipe down for previous word")
    }
    
    @ViewBuilder
    private func cardWithImage(imageUrl: String) -> some View {
        VStack(spacing: 0) {
            // Image section (top 40%)
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(LinearGradient(
                        colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .overlay {
                        ProgressView()
                            .scaleEffect(1.2)
                    }
            }
            .frame(height: cardHeight * 0.4)
            .clipped()
            
            // Content section (bottom 60%)
            VStack(spacing: 0) {
                cardContent()
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                
                Spacer()
                
                // Action buttons
                actionButtons()
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            }
            .frame(height: cardHeight * 0.6)
        }
    }
    
    @ViewBuilder
    private func cardWithoutImage() -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Content section (centered)
            cardContent()
                .padding(.horizontal, 32)
            
            Spacer()
            
            // Action buttons
            actionButtons()
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
        }
    }
    
    @ViewBuilder
    private func cardContent() -> some View {
        VStack(spacing: 16) {
            // Term and pronunciation
            VStack(spacing: 8) {
                HStack {
                    Text(card.term)
                        .font(.system(size: 32, weight: .bold, design: .default))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Pronunciation button
                    Button(action: playPronunciation) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .accessibilityLabel("Play pronunciation")
                }
                
                HStack {
                    Text(card.pronunciation)
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                    
                    Text("(\(card.partOfSpeech))")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            
            // Definition
            VStack(alignment: .leading, spacing: 12) {
                Text(card.definition)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.primary)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                
                // Example sentence
                Text(card.example)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)
                    .italic()
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Additional info (synonyms, difficulty, etc.)
            if !card.synonyms.isEmpty || card.difficulty > 0 {
                VStack(spacing: 8) {
                    Divider()
                        .padding(.vertical, 8)
                    
                    if !card.synonyms.isEmpty {
                        HStack {
                            Text("Similar:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fontWeight(.medium)
                            
                            Text(card.synonyms.prefix(3).joined(separator: ", "))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                    }
                    
                    if card.difficulty > 0 {
                        HStack {
                            Text("Difficulty:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fontWeight(.medium)
                            
                            HStack(spacing: 2) {
                                ForEach(1...5, id: \.self) { level in
                                    Circle()
                                        .fill(level <= card.difficulty ? Color.orange : Color.gray.opacity(0.3))
                                        .frame(width: 6, height: 6)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func actionButtons() -> some View {
        HStack(spacing: 40) {
            // Favorite button
            VStack(spacing: 8) {
                Button(action: toggleFavorite) {
                    Image(systemName: isFavorited ? "heart.fill" : "heart")
                        .font(.title2)
                        .foregroundColor(isFavorited ? .red : .gray)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel(isFavorited ? "Remove from favorites" : "Add to favorites")
                
                Text("Favorite")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Learn Again button
            VStack(spacing: 8) {
                Button(action: markForReview) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Learn again")
                
                Text("Learn Again")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Master button
            VStack(spacing: 8) {
                Button(action: markAsMastered) {
                    Image(systemName: isLearned ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.title2)
                        .foregroundColor(isLearned ? .green : .gray)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel(isLearned ? "Mastered" : "Mark as mastered")
                
                Text("Master")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Actions
    private func playPronunciation() {
        // Use iOS built-in text-to-speech
        let utterance = AVSpeechUtterance(string: card.term)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 0.8
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
        
        print("Playing pronunciation for: \(card.term)")
    }
    
    private func toggleFavorite() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isFavorited.toggle()
        }
        
        // Call API to update favorite status
        Task {
            do {
                try await APIService.shared.markTermRelevance(
                    userId: "default-user", // TODO: Get actual user ID
                    termId: card.id,
                    action: isFavorited ? .favorite : .markRelevant
                )
                print("Successfully toggled favorite for: \(card.term)")
            } catch {
                print("Failed to toggle favorite: \(error)")
                // Revert state on error
                withAnimation(.easeInOut(duration: 0.2)) {
                    isFavorited.toggle()
                }
            }
        }
    }
    
    private func markForReview() {
        withAnimation(.easeInOut(duration: 0.2)) {
            // Visual feedback - could add a subtle shake or color change
        }
        
        // Call API to mark for review
        Task {
            do {
                try await APIService.shared.markTermRelevance(
                    userId: "default-user", // TODO: Get actual user ID
                    termId: card.id,
                    action: .learnAgain
                )
                print("Successfully marked for review: \(card.term)")
                
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            } catch {
                print("Failed to mark for review: \(error)")
            }
        }
    }
    
    private func markAsMastered() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isLearned.toggle()
        }
        
        // Call API to mark as mastered
        Task {
            do {
                try await APIService.shared.markTermRelevance(
                    userId: "default-user", // TODO: Get actual user ID
                    termId: card.id,
                    action: isLearned ? .mastered : .markRelevant
                )
                print("Successfully marked as mastered: \(card.term)")
                
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            } catch {
                print("Failed to mark as mastered: \(error)")
                // Revert state on error
                withAnimation(.easeInOut(duration: 0.2)) {
                    isLearned.toggle()
                }
            }
        }
    }
}

// MARK: - Preview
struct VocabularyCardView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                // Card with image
                VocabularyCardView(
                    card: VocabularyCard(
                        id: "1",
                        term: "Ephemeral",
                        pronunciation: "ɪˈfemərəl",
                        partOfSpeech: "adj.",
                        definition: "Lasting for a very short time.",
                        example: "The beauty of the cherry blossoms is ephemeral, lasting only a few days.",
                        imageUrl: "https://images.unsplash.com/photo-1522383225653-ed111181a951?w=800",
                        synonyms: ["temporary", "transient", "fleeting"],
                        antonyms: ["permanent", "lasting", "enduring"],
                        relatedTerms: [],
                        difficulty: 3
                    ),
                    cardHeight: geometry.size.height * 0.45,
                    isActive: true
                )
                
                // Card without image
                VocabularyCardView(
                    card: VocabularyCard(
                        id: "2",
                        term: "Serendipity",
                        pronunciation: "ˌserənˈdɪpɪti",
                        partOfSpeech: "n.",
                        definition: "The occurrence and development of events by chance in a happy or beneficial way.",
                        example: "A fortunate stroke of serendipity led to the discovery of the new vaccine.",
                        imageUrl: nil,
                        synonyms: ["chance", "fortune", "luck"],
                        antonyms: ["misfortune", "bad luck"],
                        relatedTerms: [],
                        difficulty: 4
                    ),
                    cardHeight: geometry.size.height * 0.45,
                    isActive: false
                )
            }
        }
        .padding()
    }
}
