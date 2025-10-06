import SwiftUI

/// Simple vertical scrolling implementation using native TabView with rotation
struct SimpleVerticalScrollView: View {
    let words: [DailyWord]
    @Binding var currentIndex: Int
    let onSwipeToNext: (() async -> Void)?
    let onCardChanged: ((Int) -> Void)?
    
    init(
        words: [DailyWord],
        currentIndex: Binding<Int>,
        onSwipeToNext: (() async -> Void)? = nil,
        onCardChanged: ((Int) -> Void)? = nil
    ) {
        self.words = words
        self._currentIndex = currentIndex
        self.onSwipeToNext = onSwipeToNext
        self.onCardChanged = onCardChanged
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            
            // TabView with vertical scrolling using rotation trick
            TabView(selection: $currentIndex) {
                ForEach(Array(words.enumerated()), id: \.element.id) { index, word in
                    EnhancedDailyWordCard(dailyWord: word)
                        .frame(width: geometry.size.width, height: screenHeight)
                        .tag(index)
                        .rotationEffect(.degrees(90)) // Rotate each card back to normal
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .rotationEffect(.degrees(-90)) // Rotate the entire TabView
            .onChange(of: currentIndex) { _, newIndex in
                onCardChanged?(newIndex)
                
                // Load more cards when approaching the end
                if newIndex >= words.count - 2 {
                    Task {
                        await onSwipeToNext?()
                    }
                }
            }
        }
    }
}

#Preview {
    // Use existing preview data from DailyWord model
    SimpleVerticalScrollView(
        words: [DailyWord.previewData],
        currentIndex: .constant(0)
    )
}
