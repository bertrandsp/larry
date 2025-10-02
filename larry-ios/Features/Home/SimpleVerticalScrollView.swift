import SwiftUI

struct SimpleVerticalScrollView: View {
    @StateObject private var viewModel = VerticalCardViewModel()
    @State private var currentIndex: Int = 0
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            
            ZStack {
                // Background
                Color.black.ignoresSafeArea()
                
                // Simple TabView with PageTabViewStyle for vertical scrolling
                TabView(selection: $currentIndex) {
                    ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                        VocabularyCardView(
                            card: card,
                            cardHeight: screenHeight,
                            isActive: true
                        )
                        .frame(width: geometry.size.width, height: screenHeight)
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onAppear {
                    viewModel.loadInitialCards()
                }
                .onChange(of: currentIndex) { _, newIndex in
                    // Load more cards when approaching the end
                    viewModel.checkAndLoadMoreCards(currentIndex: newIndex)
                }
            }
        }
        .ignoresSafeArea(.all, edges: .top)
    }
}

#Preview {
    SimpleVerticalScrollView()
}
