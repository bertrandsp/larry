//
//  WordbankView.swift
//  larry-ios
//
//  Created by AI Assistant on 9/15/25.
//

import SwiftUI

/// Wordbank view showing user's saved, favorited, and mastered words
struct WordbankView: View {
    @State private var selectedTab: WordbankTab = .favorites
    
    enum WordbankTab: String, CaseIterable {
        case favorites = "Favorites"
        case wantToMaster = "Want to Master"
        case mastered = "Mastered"
        case history = "History"
        
        var systemImage: String {
            switch self {
            case .favorites: return "heart.fill"
            case .wantToMaster: return "target"
            case .mastered: return "checkmark.circle.fill"
            case .history: return "clock.fill"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Tab picker
                Picker("Wordbank Section", selection: $selectedTab) {
                    ForEach(WordbankTab.allCases, id: \.self) { tab in
                        Label(tab.rawValue, systemImage: tab.systemImage)
                            .tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                
                // Content based on selected tab
                Group {
                    switch selectedTab {
                    case .favorites:
                        ComingSoonView(
                            title: "Favorites",
                            description: "Your favorited words will appear here"
                        )
                    case .wantToMaster:
                        ComingSoonView(
                            title: "Want to Master",
                            description: "Words you've marked for additional practice"
                        )
                    case .mastered:
                        ComingSoonView(
                            title: "Mastered Words",
                            description: "Words you've successfully mastered"
                        )
                    case .history:
                        ComingSoonView(
                            title: "Learning History",
                            description: "Your complete vocabulary learning journey"
                        )
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Wordbank")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    WordbankView()
}

