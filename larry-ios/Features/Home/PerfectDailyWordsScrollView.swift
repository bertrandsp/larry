import SwiftUI

struct PerfectDailyWordsScrollView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var currentWords: [DailyWord] = []
    @State private var preloadedWords: [DailyWord] = []
    @State private var isPreloading = false
    @State private var currentIndex: Int = 0
    @State private var hasInitialized = false
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            
            ZStack {
                // Background
                Color.black.ignoresSafeArea()
                
                switch viewModel.dailyWords {
                case .idle:
                    ProgressView("Loading...")
                        .foregroundColor(.white)
                    
                case .loading:
                    ProgressView("Loading daily words...")
                        .foregroundColor(.white)
                    
                case .success(let response):
                    if response.words.isEmpty && currentWords.isEmpty {
                        emptyStateView
                    } else {
                        // Use currentWords + preloadedWords for display
                        let wordsToShow = currentWords.isEmpty ? response.words : (currentWords + preloadedWords)
                        
                        // Use VerticalTabView with EnhancedDailyWordCard for best of both worlds
                        VerticalTabView(
                            cardCount: wordsToShow.count,
                            onSwipeToNext: { await handleSwipeToNext() },
                            onCardChanged: { index in
                                currentIndex = index
                                // Trigger preload when nearing the end
                                if index >= wordsToShow.count - 2 {
                                    Task {
                                        await preloadNextWords()
                                    }
                                }
                            }
                        ) {
                            ForEach(Array(wordsToShow.enumerated()), id: \.element.id) { index, dailyWord in
                                EnhancedDailyWordCard(dailyWord: dailyWord)
                                    .frame(width: geometry.size.width, height: screenHeight)
                                    .id(index)
                            }
                        }
                    }
                    
                case .error(let error):
                    errorStateView(error: error)
                }
            }
        }
        .ignoresSafeArea(.all, edges: .top)
        .onAppear {
            initializeWords()
        }
    }
    
    // MARK: - State Views
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Words Available")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Complete onboarding to get your first vocabulary words")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private func errorStateView(error: Error) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Error Loading Words")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again") {
                Task {
                    await viewModel.loadDailyWords()
                }
            }
            .foregroundColor(.blue)
            .padding()
            .background(Color.blue.opacity(0.2))
            .cornerRadius(10)
        }
    }
    
    
    // MARK: - Data Loading
    
    private func initializeWords() {
        // Prevent multiple initializations
        guard !hasInitialized else { return }
        hasInitialized = true
        
        // Initialize words from the viewModel data without triggering additional loads
        if case .success(let response) = viewModel.dailyWords {
            currentWords = response.words
            // Start preloading in background
            Task {
                await preloadNextWords(count: 2)
            }
        }
    }
    
    private func handleSwipeToNext() async {
        // User swiped to next, ensure we have preloaded words
        if preloadedWords.isEmpty {
            await preloadNextWords(count: 1)
        }
        
        // Move the next preloaded word to current words
        if !preloadedWords.isEmpty {
            let nextWord = preloadedWords.removeFirst()
            currentWords.append(nextWord)
            
            #if DEBUG
            print("🎯 Swiped to next word: \(nextWord.term.term)")
            #endif
            
            // Trigger another preload to keep the buffer full
            if preloadedWords.count < 2 {
                Task {
                    await preloadNextWords(count: 3)
                }
            }
        }
    }
    
    private func checkAndLoadMoreCards(currentIndex: Int) {
        // Load more cards when user reaches second-to-last card
        let wordsToShow = currentWords.isEmpty ? (viewModel.dailyWords.data?.words ?? []) : (currentWords + preloadedWords)
        if currentIndex >= wordsToShow.count - 2 {
            Task {
                await preloadNextWords()
            }
        }
    }
    
    private func preloadNextWords(count: Int = 2) async {
        guard !isPreloading else { return }
        
        isPreloading = true
        
        do {
            // Load multiple words at once
            var newWords: [DailyWord] = []
            
            for _ in 0..<count {
                let response = try await APIService.shared.getNextUnseenWord()
                if !response.words.isEmpty {
                    newWords.append(response.words[0])
                    
                    #if DEBUG
                    print("🚀 Preloaded word: \(response.words[0].term.term)")
                    #endif
                }
            }
            
            // Add preloaded words to the cache
            if !newWords.isEmpty {
                // Move current preloaded words to current words if user already swiped past them
                if currentIndex >= currentWords.count {
                    let wordsToMove = preloadedWords.prefix(currentIndex - currentWords.count + 1)
                    currentWords.append(contentsOf: wordsToMove)
                    preloadedWords.removeFirst(wordsToMove.count)
                }
                
                // Add new words to preloaded cache
                preloadedWords.append(contentsOf: newWords)
                
                #if DEBUG
                print("✅ Preloading complete: \(preloadedWords.count) words cached")
                #endif
            }
        } catch {
            #if DEBUG
            print("❌ Failed to preload words: \(error)")
            #endif
        }
        
        isPreloading = false
    }
    
    // MARK: - Accessibility
    
    private func announceCardChange(for dailyWord: DailyWord?) {
        guard let dailyWord = dailyWord else { return }
        
        let wordsToShow = currentWords.isEmpty ? (viewModel.dailyWords.data?.words ?? []) : (currentWords + preloadedWords)
        let announcement = "Card \(currentIndex + 1) of \(wordsToShow.count). \(dailyWord.term.term). \(dailyWord.term.definition)"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            UIAccessibility.post(notification: .announcement, argument: announcement)
        }
    }
}


// MARK: - Preview

#Preview {
    PerfectDailyWordsScrollView()
        .environmentObject(HomeViewModel())
}
