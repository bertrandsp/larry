//
//  TestEnhancedVocabulary.swift
//  larry-ios
//
//  Created by AI Assistant on 10/1/25.
//

import SwiftUI

/// Test view to verify enhanced vocabulary integration
struct TestEnhancedVocabularyView: View {
    @State private var testWord: FirstDailyWord?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if isLoading {
                        ProgressView("Loading enhanced vocabulary...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = errorMessage {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 48))
                                .foregroundColor(.orange)
                            
                            Text("Error")
                                .font(.headline)
                            
                            Text(error)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Try Again") {
                                loadTestData()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                    } else if let word = testWord {
                        EnhancedDailyWordCard(dailyWord: word.toDailyWord())
                    } else {
                        VStack(spacing: 16) {
                            Text("Enhanced Vocabulary Test")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Tap the button below to test the enhanced vocabulary features with real backend data.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Load Enhanced Vocabulary") {
                                loadTestData()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Enhanced Vocabulary Test")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            // Auto-load test data on appear
            loadTestData()
        }
    }
    
    private func loadTestData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Test with a fresh user to get enhanced vocabulary
                let response = try await APIService.shared.getFirstDailyWord(
                    userId: "email-user-freshvocabtestexamplecom"
                )
                
                await MainActor.run {
                    if response.success, let dailyWord = response.dailyWord {
                        testWord = dailyWord
                        print("✅ Enhanced vocabulary loaded successfully:")
                        print("   Term: \(dailyWord.term)")
                        print("   Synonyms: \(dailyWord.synonyms)")
                        print("   Antonyms: \(dailyWord.antonyms)")
                        print("   Related Terms: \(dailyWord.relatedTerms.count)")
                        print("   Part of Speech: \(dailyWord.partOfSpeech ?? "N/A")")
                        print("   Difficulty: \(dailyWord.difficulty ?? 0)")
                        print("   Tags: \(dailyWord.tags)")
                    } else {
                        errorMessage = response.message ?? "Failed to load enhanced vocabulary"
                    }
                    isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                    print("❌ Failed to load enhanced vocabulary: \(error)")
                }
            }
        }
    }
}

#Preview {
    TestEnhancedVocabularyView()
}
