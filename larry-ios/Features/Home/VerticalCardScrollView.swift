import SwiftUI

struct VerticalCardScrollView: View {
    @StateObject private var viewModel = VerticalCardViewModel()
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isSnapping: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            let cardHeight = geometry.size.height
            
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                            VocabularyCardView(
                                card: card,
                                cardHeight: cardHeight,
                                isActive: index == currentIndex
                            )
                            .frame(height: cardHeight)
                            .id(index)
                        }
                    }
                }
                .scrollDisabled(false)
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            if !isSnapping {
                                dragOffset = value.translation.height
                            }
                        }
                        .onEnded { value in
                            handleSwipeGesture(
                                translation: value.translation.height,
                                velocity: value.velocity.height,
                                proxy: proxy,
                                cardHeight: cardHeight
                            )
                        }
                )
                .onAppear {
                    viewModel.loadInitialCards()
                }
                .onChange(of: currentIndex) { _, newIndex in
                    // Announce card change for VoiceOver
                    announceCardChange(for: viewModel.cards[safe: newIndex])
                    
                    // Preload strategy: load more cards if needed
                    viewModel.checkAndLoadMoreCards(currentIndex: newIndex)
                }
            }
        }
        .clipped()
        .ignoresSafeArea(.all, edges: .top)
    }
    
    private func handleSwipeGesture(
        translation: CGFloat,
        velocity: CGFloat,
        proxy: Any,
        cardHeight: CGFloat
    ) {
        guard !isSnapping else { return }
        
        let threshold: CGFloat = cardHeight * 0.25 // 25% of card height
        let velocityThreshold: CGFloat = 500
        
        var targetIndex = currentIndex
        
        // Determine direction based on translation and velocity
        if translation < -threshold || velocity < -velocityThreshold {
            // Swipe up - next card
            targetIndex = min(currentIndex + 1, viewModel.cards.count - 1)
        } else if translation > threshold || velocity > velocityThreshold {
            // Swipe down - previous card
            targetIndex = max(currentIndex - 1, 0)
        }
        
        // Snap to target card
        snapToCard(index: targetIndex, proxy: proxy)
    }
    
    private func snapToCard(index: Int, proxy: Any) {
        guard index != currentIndex else { return }
        
        isSnapping = true
        dragOffset = 0
        
        withAnimation(.easeOut(duration: 0.3)) {
            // Update the current index - TabView will handle the scrolling automatically
            currentIndex = index
        }
        
        // Reset snapping flag after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isSnapping = false
        }
    }
    
    private func announceCardChange(for card: VocabularyCard?) {
        guard let card = card else { return }
        
        let announcement = "\(card.term). \(card.definition)"
        
        // Post accessibility announcement
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(notification: .announcement, argument: announcement)
        }
    }
}

// MARK: - ViewModel
@MainActor
class VerticalCardViewModel: ObservableObject {
    @Published var cards: [VocabularyCard] = []
    @Published var isLoading: Bool = false
    
    private let apiService = APIService.shared
    private var hasLoadedInitial = false
    
    func loadInitialCards() {
        guard !hasLoadedInitial else { return }
        hasLoadedInitial = true
        
        Task {
            loadMoreCards()
        }
    }
    
    func checkAndLoadMoreCards(currentIndex: Int) {
        // Load more cards when user reaches second-to-last card
        if currentIndex >= cards.count - 2 {
            Task {
                loadMoreCards()
            }
        }
    }
    
    @MainActor
    private func loadMoreCards() {
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            do {
                // Try to load from enhanced vocabulary API first
                if let enhancedWord = try await loadEnhancedVocabulary() {
                    let newCard = convertToVocabularyCard(from: enhancedWord)
                    cards.append(newCard)
                } else {
                    // Fallback to mock cards for development
                    let newCards = createMockCards(count: 5)
                    cards.append(contentsOf: newCards)
                }
            } catch {
                print("Error loading cards: \(error)")
                // Fallback to mock cards on error
                let newCards = createMockCards(count: 3)
                cards.append(contentsOf: newCards)
            }
            
            isLoading = false
        }
    }
    
    private func loadEnhancedVocabulary() async throws -> EnhancedFirstDailyWordResponse? {
        // Try to get enhanced vocabulary from API
        do {
            return try await apiService.getFirstDailyWord(userId: "default-user")
        } catch {
            print("Failed to load enhanced vocabulary: \(error)")
            return nil
        }
    }
    
    private func convertToVocabularyCard(from response: EnhancedFirstDailyWordResponse) -> VocabularyCard {
        guard let dailyWord = response.dailyWord else {
            // Return a default card if dailyWord is nil
            return VocabularyCard(
                id: UUID().uuidString,
                term: "Welcome",
                pronunciation: "ˈwelkəm",
                partOfSpeech: "n.",
                definition: "A greeting or reception.",
                example: "Welcome to Larry!",
                imageUrl: nil,
                synonyms: ["greeting", "reception"],
                antonyms: ["farewell", "goodbye"],
                relatedTerms: [],
                difficulty: 1
            )
        }
        
        return VocabularyCard(
            id: dailyWord.id,
            term: dailyWord.term,
            pronunciation: dailyWord.pronunciation ?? "",
            partOfSpeech: dailyWord.partOfSpeech ?? "",
            definition: dailyWord.definition,
            example: dailyWord.example ?? "",
            imageUrl: nil, // Add image URL support later
            synonyms: dailyWord.synonyms,
            antonyms: dailyWord.antonyms,
            relatedTerms: dailyWord.relatedTerms.map { $0.term },
            difficulty: dailyWord.difficulty ?? 1
        )
    }
    
    private func createMockCards(count: Int) -> [VocabularyCard] {
        let mockTerms = [
            ("Ephemeral", "ɪˈfemərəl", "adj.", "Lasting for a very short time.", "The beauty of the cherry blossoms is ephemeral, lasting only a few days.", "https://images.unsplash.com/photo-1522383225653-ed111181a951?w=800"),
            ("Ubiquitous", "juːˈbɪkwɪtəs", "adj.", "Present, appearing, or found everywhere.", "In the modern world, smartphones have become ubiquitous.", "https://images.unsplash.com/photo-1556656793-08538906a9f8?w=800"),
            ("Mellifluous", "məˈlɪfluəs", "adj.", "Sweet or musical; pleasant to hear.", "Her mellifluous voice captivated the audience.", "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800"),
            ("Serendipity", "ˌserənˈdɪpɪti", "n.", "The occurrence and development of events by chance in a happy or beneficial way.", "A fortunate stroke of serendipity led to the discovery of the new vaccine.", "https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=800"),
            ("Luminous", "ˈluːmɪnəs", "adj.", "Full of or shedding light; bright or shining.", "The luminous moon cast a silver glow over the lake.", nil)
        ]
        
        return (0..<count).map { index in
            let termData = mockTerms[index % mockTerms.count]
            return VocabularyCard(
                id: UUID().uuidString,
                term: termData.0,
                pronunciation: termData.1,
                partOfSpeech: termData.2,
                definition: termData.3,
                example: termData.4,
                imageUrl: termData.5,
                synonyms: ["temporary", "transient", "fleeting"],
                antonyms: ["permanent", "lasting", "enduring"],
                relatedTerms: [],
                difficulty: Int.random(in: 1...5)
            )
        }
    }
}

// MARK: - Data Model
struct VocabularyCard: Identifiable, Codable {
    let id: String
    let term: String
    let pronunciation: String
    let partOfSpeech: String
    let definition: String
    let example: String
    let imageUrl: String?
    let synonyms: [String]
    let antonyms: [String]
    let relatedTerms: [String]
    let difficulty: Int
}

// MARK: - Safe Array Extension
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
