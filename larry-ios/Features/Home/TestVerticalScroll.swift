import SwiftUI

struct TestVerticalScroll: View {
    @State private var currentIndex: Int = 0
    
    // Simple mock data for testing
    private let testCards = [
        VocabularyCard(
            id: "1",
            term: "Ephemeral",
            pronunciation: "ɪˈfemərəl",
            partOfSpeech: "adj.",
            definition: "Lasting for a very short time.",
            example: "The beauty of the cherry blossoms is ephemeral, lasting only a few days.",
            imageUrl: nil,
            synonyms: ["temporary", "transient", "fleeting"],
            antonyms: ["permanent", "lasting", "eternal"],
            relatedTerms: ["momentary", "brief"],
            difficulty: 2
        ),
        VocabularyCard(
            id: "2",
            term: "Serendipity",
            pronunciation: "ˌserənˈdipədē",
            partOfSpeech: "n.",
            definition: "The occurrence of events by chance in a happy or beneficial way.",
            example: "Meeting my best friend was pure serendipity.",
            imageUrl: nil,
            synonyms: ["luck", "fortune", "chance"],
            antonyms: ["misfortune", "bad luck"],
            relatedTerms: ["coincidence", "fate"],
            difficulty: 3
        ),
        VocabularyCard(
            id: "3",
            term: "Ubiquitous",
            pronunciation: "yo͞oˈbikwədəs",
            partOfSpeech: "adj.",
            definition: "Present, appearing, or found everywhere.",
            example: "Smartphones have become ubiquitous in modern society.",
            imageUrl: nil,
            synonyms: ["omnipresent", "pervasive", "widespread"],
            antonyms: ["rare", "scarce", "limited"],
            relatedTerms: ["universal", "global"],
            difficulty: 3
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            
            ZStack {
                // Background
                Color.black.ignoresSafeArea()
                
                // Vertical scrolling with snap behavior
                VerticalTabView {
                    ForEach(Array(testCards.enumerated()), id: \.element.id) { index, card in
                        VocabularyCardView(
                            card: card,
                            cardHeight: screenHeight,
                            isActive: true
                        )
                        .frame(width: geometry.size.width, height: screenHeight)
                        .id(index)
                    }
                }
            }
        }
        .ignoresSafeArea(.all, edges: .top)
    }
}

#Preview {
    TestVerticalScroll()
}