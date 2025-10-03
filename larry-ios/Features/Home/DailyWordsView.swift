import SwiftUI

struct DailyWordsView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    
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
                    if response.words.isEmpty {
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
                        // Convert DailyWord to VocabularyCard and display
                        VerticalTabView {
                            ForEach(Array(response.words.enumerated()), id: \.element.id) { index, dailyWord in
                                let vocabularyCard = convertToVocabularyCard(from: dailyWord)
                                
                                VocabularyCardView(
                                    card: vocabularyCard,
                                    cardHeight: screenHeight,
                                    isActive: true
                                )
                                .frame(width: geometry.size.width, height: screenHeight)
                                .id(index)
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
                await viewModel.loadDailyWords()
            }
        }
    }
    
    private func convertToVocabularyCard(from dailyWord: DailyWord) -> VocabularyCard {
        return VocabularyCard(
            id: dailyWord.id,
            term: dailyWord.term.term,
            pronunciation: dailyWord.term.pronunciation ?? "",
            partOfSpeech: dailyWord.term.partOfSpeech ?? "",
            definition: dailyWord.term.definition,
            example: dailyWord.term.example,
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
