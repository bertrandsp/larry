import SwiftUI

struct DailyWordsView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @StateObject private var realTimeService = RealTimeService()
    @State private var showingConnectionStatus = false
    @State private var currentWords: [DailyWord] = []
    @State private var preloadedWords: [DailyWord] = []
    @State private var isPreloading = false
    @State private var currentIndex: Int = 0
    
    var body: some View {
        ZStack {
            // Main content with enhanced loading states
            GeometryReader { geometry in
                let screenHeight = geometry.size.height
                
                ZStack {
                    // Background
                    Color.black.ignoresSafeArea()
                    
                    // Content based on state
                    switch viewModel.dailyWords {
                    case .idle:
                        enhancedLoadingView
                        
                    case .loading:
                        enhancedLoadingView
                        
                    case .success(let response):
                        if response.words.isEmpty && (viewModel.firstDailyWord.data?.dailyWord == nil) {
                            enhancedEmptyView
                        } else {
                            // Use currentWords + preloadedWords for display with swipe functionality
                            let wordsToShow = currentWords.isEmpty ? response.words : (currentWords + preloadedWords)
                            
                            if wordsToShow.isEmpty && (viewModel.firstDailyWord.data?.dailyWord == nil) {
                                enhancedEmptyView
                            } else {
                                VStack(spacing: 0) {
                                    // First daily word section
                                    firstDailyWordSection
                                    
                                    // Simple vertical scrolling with TabView
                                    if !wordsToShow.isEmpty {
                                        SimpleVerticalScrollView(
                                            words: wordsToShow,
                                            currentIndex: $currentIndex,
                                            onSwipeToNext: { await handleSwipeToNext() },
                                            onCardChanged: { index in
                                                // Trigger preload when nearing the end
                                                if index >= wordsToShow.count - 2 {
                                                    Task {
                                                        await preloadNextWords()
                                                    }
                                                }
                                            }
                                        )
                                    }
                                }
                            }
                        }
                        
                    case .error(let error):
                        enhancedErrorView(error: error)
                    }
                }
            }
            
            // Real-time status indicator
            VStack {
                HStack {
                    Spacer()
                    
                    // Connection status indicator
                    Button(action: {
                        showingConnectionStatus.toggle()
                    }) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(realTimeService.isConnected ? Color.green : Color.red)
                                .frame(width: 8, height: 8)
                                .scaleEffect(realTimeService.isConnected ? 1.0 : 0.8)
                                .animation(
                                    Animation.easeInOut(duration: 2).repeatForever(autoreverses: true),
                                    value: realTimeService.isConnected
                                )
                            
                            Text(realTimeService.isConnected ? "Live" : "Offline")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                Spacer()
            }
        }
        .onAppear {
            // Initialize words from viewModel data
            initializeWords()
            
            // Connect to real-time service
            realTimeService.onNewWordsAvailable = {
                Task { @MainActor in
                    await viewModel.smartRefresh()
                }
            }
            realTimeService.connect()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            viewModel.handleAppBecameActive()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            viewModel.handleAppWillResignActive()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            viewModel.handleAppDidEnterBackground()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            viewModel.handleAppWillEnterForeground()
        }
        .refreshable {
            await viewModel.refreshData()
        }
        .alert("Connection Status", isPresented: $showingConnectionStatus) {
            Button("OK") { }
        } message: {
            Text(connectionStatusMessage)
        }
        .onChange(of: currentWords.count) { oldValue, newValue in
            #if DEBUG
            print("📊 ===== WORDS STATE CHANGED =====")
            print("📊 currentWords count: \(currentWords.count)")
            print("📊 preloadedWords count: \(preloadedWords.count)")
            print("📊 currentWords: \(currentWords.map { $0.term.term })")
            print("📊 preloadedWords: \(preloadedWords.map { $0.term.term })")
            print("📊 ==================================")
            #endif
        }
        .onChange(of: preloadedWords.count) { oldValue, newValue in
            #if DEBUG
            print("📊 ===== PRELOADED WORDS CHANGED =====")
            print("📊 currentWords count: \(currentWords.count)")
            print("📊 preloadedWords count: \(preloadedWords.count)")
            print("📊 currentWords: \(currentWords.map { $0.term.term })")
            print("📊 preloadedWords: \(preloadedWords.map { $0.term.term })")
            print("📊 =====================================")
            #endif
        }
        .onReceive(viewModel.$dailyWords) { newState in
            if case .success(let response) = newState, currentWords.isEmpty {
                #if DEBUG
                print("🎬 Daily words loaded, initializing with \(response.words.count) words")
                #endif
                
                currentWords = response.words
                
                // Start preloading in background
                Task {
                    #if DEBUG
                    print("🎬 Starting preload of 2 additional words...")
                    #endif
                    await preloadNextWords(count: 2)
                }
            }
        }
    }
    
    private var connectionStatusMessage: String {
        switch realTimeService.connectionStatus {
        case .connected:
            return "Connected to real-time updates. New words will appear instantly!"
        case .connecting:
            return "Connecting to real-time service..."
        case .reconnecting:
            return "Reconnecting... (\(realTimeService.reconnectAttempts) attempts)"
        case .failed:
            return "Connection failed. Using periodic refresh instead."
        case .disconnected:
            return "Disconnected. Manual refresh required."
        }
    }
    
    // MARK: - Swipe Handling Functions
    
    private func initializeWords() {
        // Initialize words from the viewModel data
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
            
            // Add preloaded words to the cache with deduplication
            if !newWords.isEmpty {
                // Move current preloaded words to current words if user already swiped past them
                if currentIndex >= currentWords.count {
                    let wordsToMove = preloadedWords.prefix(currentIndex - currentWords.count + 1)
                    currentWords.append(contentsOf: wordsToMove)
                    preloadedWords.removeFirst(wordsToMove.count)
                }
                
                // Get all existing term IDs to prevent duplicates
                let existingTermIds = Set(currentWords.map { $0.term.id } + preloadedWords.map { $0.term.id })
                
                // Filter out duplicates before adding to preloaded cache
                let uniqueNewWords = newWords.filter { !existingTermIds.contains($0.term.id) }
                
                if !uniqueNewWords.isEmpty {
                    preloadedWords.append(contentsOf: uniqueNewWords)
                    
                    #if DEBUG
                    print("✅ Preloading complete: \(uniqueNewWords.count) unique words added, \(preloadedWords.count) total cached")
                    if uniqueNewWords.count < newWords.count {
                        print("⚠️ Filtered out \(newWords.count - uniqueNewWords.count) duplicate words")
                    }
                    #endif
                } else {
                    #if DEBUG
                    print("⚠️ All \(newWords.count) preloaded words were duplicates, skipped")
                    #endif
                }
            }
        } catch {
            #if DEBUG
            print("❌ Failed to preload words: \(error)")
            #endif
        }
        
        isPreloading = false
    }
    
    // MARK: - Enhanced View Components
    
    private var enhancedLoadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.white)
            
            Text("Loading your words...")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Checking for new vocabulary...")
                .font(.caption)
                .foregroundColor(.gray)
            
            if realTimeService.isConnected {
                Text("Connected to real-time updates")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 48)
    }
    
    private var enhancedEmptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Words Available")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("New vocabulary words will appear here as they're generated.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            HStack(spacing: 12) {
                Button("Check for Updates") {
                    Task {
                        await viewModel.refreshData()
                    }
                }
                .buttonStyle(.bordered)
                
                if !realTimeService.isConnected {
                    Button("Connect Live Updates") {
                        realTimeService.connect()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(.vertical, 48)
    }
    
    private func enhancedErrorView(error: Error) -> some View {
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
                .padding(.horizontal, 32)
            
            HStack(spacing: 12) {
                Button("Retry") {
                    Task {
                        await viewModel.refreshData()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Check Connection") {
                    Task {
                        await viewModel.loadDailyWords()
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 48)
    }
    
    private var firstDailyWordSection: some View {
        Group {
            switch viewModel.firstDailyWord {
            case .loading:
                VStack(spacing: 12) {
                    ProgressView("Generating your first word...")
                        .frame(maxWidth: .infinity)
                        .tint(.white)
                    
                    Text("This may take 30-60 seconds")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 24)
                
            case .success(let response):
                if let firstWord = response.dailyWord {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Your First Word")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("New!")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                        
                        EnhancedDailyWordCard(dailyWord: firstWord.toDailyWord())
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                
            case .error(let error):
                VStack(spacing: 12) {
                    Text("Failed to generate first word")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Button("Try Again") {
                        Task {
                            await viewModel.loadFirstDailyWord()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.vertical, 16)
                
            case .idle:
                EmptyView()
            }
        }
    }
}

#Preview {
    DailyWordsView()
        .environmentObject(HomeViewModel())
}
