import SwiftUI

struct PerfectDailyWordsScrollView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var currentWords: [DailyWord] = []
    @State private var preloadedWords: [DailyWord] = []
    @State private var isPreloading = false
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isSnapping: Bool = false
    @State private var scrollProxy: ScrollViewProxy?
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
                        
                        // Main scroll container
                        ScrollViewReader { proxy in
                            ScrollView(.vertical, showsIndicators: false) {
                                LazyVStack(spacing: 0) {
                                    ForEach(Array(wordsToShow.enumerated()), id: \.element.id) { index, dailyWord in
                                        EnhancedDailyWordCard(dailyWord: dailyWord)
                                            .frame(width: geometry.size.width, height: screenHeight)
                                            .id(index)
                                            .clipped()
                                            .scaleEffect(getScaleEffect(for: index))
                                            .opacity(getOpacity(for: index))
                                            .animation(.easeOut(duration: 0.3), value: currentIndex)
                                    }
                                }
                            }
                            .scrollDisabled(true) // We handle scrolling manually
                            .offset(y: dragOffset) // Apply drag offset for visual feedback
                            .onAppear {
                                scrollProxy = proxy
                                initializeWords()
                            }
                            .simultaneousGesture(
                                DragGesture()
                                    .onChanged { value in
                                        handleDragChanged(value: value, screenHeight: screenHeight)
                                    }
                                    .onEnded { value in
                                        handleDragEnded(value: value, screenHeight: screenHeight, proxy: proxy)
                                    }
                            )
                        }
                        
                        // Subtle page indicator (optional)
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                VStack(spacing: 4) {
                                    ForEach(0..<min(wordsToShow.count, 5), id: \.self) { index in
                                        Circle()
                                            .fill(index == currentIndex ? Color.white : Color.white.opacity(0.3))
                                            .frame(width: 6, height: 6)
                                            .animation(.easeInOut(duration: 0.2), value: currentIndex)
                                    }
                                }
                                .padding(.trailing, 20)
                                .padding(.bottom, 100)
                            }
                        }
                    }
                    
                case .error(let error):
                    errorStateView(error: error)
                }
            }
        }
        .ignoresSafeArea()
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Ensure proper state when app becomes active
            if !isSnapping {
                snapToCurrentCard()
            }
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
    
    // MARK: - Gesture Handling
    
    private func handleDragChanged(value: DragGesture.Value, screenHeight: CGFloat) {
        guard !isSnapping else { return }
        
        // Provide subtle visual feedback during drag
        let translation = value.translation.height
        dragOffset = translation
        
        // Optional: Add subtle resistance at boundaries
        let wordsToShow = currentWords.isEmpty ? (viewModel.dailyWords.data?.words ?? []) : (currentWords + preloadedWords)
        if (currentIndex == 0 && translation > 0) || 
           (currentIndex == wordsToShow.count - 1 && translation < 0) {
            dragOffset = translation * 0.3 // Reduce drag effect at boundaries
        }
    }
    
    private func handleDragEnded(value: DragGesture.Value, screenHeight: CGFloat, proxy: ScrollViewProxy) {
        guard !isSnapping else { return }
        
        let translation = value.translation.height
        let velocity = value.velocity.height
        
        // More sensitive thresholds for better UX
        let translationThreshold: CGFloat = screenHeight * 0.12 // 12% of screen
        let velocityThreshold: CGFloat = 600
        
        let wordsToShow = currentWords.isEmpty ? (viewModel.dailyWords.data?.words ?? []) : (currentWords + preloadedWords)
        var targetIndex = currentIndex
        
        // Determine swipe direction with velocity consideration
        if translation < -translationThreshold || velocity < -velocityThreshold {
            // Swipe up - next card
            targetIndex = min(currentIndex + 1, wordsToShow.count - 1)
        } else if translation > translationThreshold || velocity > velocityThreshold {
            // Swipe down - previous card
            targetIndex = max(currentIndex - 1, 0)
        }
        
        // Always snap, even if staying on same card
        snapToCard(index: targetIndex, proxy: proxy)
    }
    
    private func snapToCard(index: Int, proxy: ScrollViewProxy) {
        let wordsToShow = currentWords.isEmpty ? (viewModel.dailyWords.data?.words ?? []) : (currentWords + preloadedWords)
        guard index >= 0 && index < wordsToShow.count else { return }
        
        isSnapping = true
        dragOffset = 0
        
        // Smooth spring animation with actual scrolling
        withAnimation(.interpolatingSpring(stiffness: 280, damping: 28, initialVelocity: 0)) {
            currentIndex = index
            proxy.scrollTo(index, anchor: UnitPoint.top)
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Announce for accessibility
        announceCardChange(for: wordsToShow[safe: index])
        
        // Check if we need to load more cards
        checkAndLoadMoreCards(currentIndex: index)
        
        // Reset snapping flag with proper timing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isSnapping = false
        }
    }
    
    private func snapToCurrentCard() {
        guard let proxy = scrollProxy else { return }
        snapToCard(index: currentIndex, proxy: proxy)
    }
    
    // MARK: - Visual Effects
    
    private func getScaleEffect(for index: Int) -> CGFloat {
        if index == currentIndex {
            return 1.0
        } else if abs(index - currentIndex) == 1 {
            return 0.95 // Slightly smaller for adjacent cards
        } else {
            return 0.9
        }
    }
    
    private func getOpacity(for index: Int) -> Double {
        if index == currentIndex {
            return 1.0
        } else if abs(index - currentIndex) == 1 {
            return 0.7 // Slightly transparent for adjacent cards
        } else {
            return 0.3
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
