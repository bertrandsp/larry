import SwiftUI

struct DailyWordsView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var currentWords: [DailyWord] = []
    @State private var isLoadingNext = false
    
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
                    } else {
                        // Use currentWords for display, initialize with first response if empty
                        let wordsToShow = currentWords.isEmpty ? response.words : currentWords
                        
                        // Convert DailyWord to VocabularyCard and display
                        VerticalTabView(onSwipeToNext: loadNextWord) {
                            ForEach(Array(wordsToShow.enumerated()), id: \.element.id) { index, dailyWord in
                                let vocabularyCard = convertToVocabularyCard(from: dailyWord)
                                
                                VocabularyCardView(
                                    card: vocabularyCard,
                                    cardHeight: screenHeight,
                                    isActive: true
                                )
                                .frame(width: geometry.size.width, height: screenHeight)
                                .id(index)
                                .overlay(
                                    // Loading indicator for next word
                                    isLoadingNext ? 
                                    ProgressView()
                                        .scaleEffect(1.5)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .background(Color.black.opacity(0.3))
                                    : nil
                                )
                            }
                        }
                    }
                    
                case .error(let error):
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
            }
        }
        .ignoresSafeArea(.all, edges: .top)
        .onAppear {
            Task {
                await loadInitialWords()
            }
        }
    }
    
    private func loadInitialWords() async {
        await viewModel.loadDailyWords()
        if case .success(let response) = viewModel.dailyWords {
            currentWords = response.words
        }
    }
    
    private func loadNextWord() async {
        guard !isLoadingNext else { return }
        
        isLoadingNext = true
        
        do {
            let response = try await APIService.shared.getNextUnseenWord()
            if !response.words.isEmpty {
                // Add the new word to current words
                currentWords.append(response.words[0])
                
                #if DEBUG
                print("✅ Loaded next unseen word: \(response.words[0].term.term)")
                #endif
            }
        } catch {
            #if DEBUG
            print("❌ Failed to load next unseen word: \(error)")
            #endif
        }
        
        isLoadingNext = false
    }
    
    private func convertToVocabularyCard(from dailyWord: DailyWord) -> VocabularyCard {
        return VocabularyCard(
            id: dailyWord.id,
            term: dailyWord.term.term,
            pronunciation: dailyWord.term.pronunciation ?? "",
            partOfSpeech: dailyWord.term.partOfSpeech ?? "",
            definition: dailyWord.term.definition,
            example: dailyWord.term.example ?? "",
            imageUrl: nil,
            synonyms: dailyWord.term.synonyms,
            antonyms: dailyWord.term.antonyms,
            relatedTerms: dailyWord.term.relatedTerms.map { rt in
                rt.term
            },
            difficulty: dailyWord.term.difficulty ?? 1
        )
    }
}

#Preview {
    DailyWordsView()
        .environmentObject(HomeViewModel())
}
