import SwiftUI

struct WordbankView: View {
    @EnvironmentObject private var apiService: APIService
    @State private var searchText = ""
    @State private var selectedFilter: WordbankFilter = .all
    @State private var terms: [Term] = []
    @State private var isLoading = false
    
    enum WordbankFilter: String, CaseIterable {
        case all = "All"
        case favorites = "Favorites"
        case mastered = "Mastered"
        case learning = "Learning"
        
        var systemImage: String {
            switch self {
            case .all:
                return "book.fill"
            case .favorites:
                return "heart.fill"
            case .mastered:
                return "checkmark.circle.fill"
            case .learning:
                return "clock.fill"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                searchBar
                
                // Filter tabs
                filterTabs
                
                // Terms list
                if isLoading {
                    loadingView
                } else if filteredTerms.isEmpty {
                    emptyStateView
                } else {
                    termsList
                }
            }
            .navigationTitle("Wordbank")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            await loadTerms()
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search words...", text: $searchText)
                .textFieldStyle(.plain)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(WordbankFilter.allCases, id: \.self) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: filter.systemImage)
                                .font(.caption)
                            
                            Text(filter.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedFilter == filter ? Color.blue : Color(.systemGray6))
                        .foregroundColor(selectedFilter == filter ? .white : .primary)
                        .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading your wordbank...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 50)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: selectedFilter.systemImage)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No words found")
                .font(.title2)
                .fontWeight(.medium)
            
            Text(emptyStateMessage)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 50)
        .padding(.horizontal)
    }
    
    private var termsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredTerms) { term in
                    WordbankTermCard(term: term)
                }
            }
            .padding()
        }
    }
    
    private var filteredTerms: [Term] {
        let filtered = terms.filter { term in
            switch selectedFilter {
            case .all:
                return true
            case .favorites:
                return term.isFavorite
            case .mastered:
                return term.isMastered
            case .learning:
                return !term.isMastered && term.timesStudied > 0
            }
        }
        
        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter { term in
                term.word.localizedCaseInsensitiveContains(searchText) ||
                term.definition.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var emptyStateMessage: String {
        switch selectedFilter {
        case .all:
            return searchText.isEmpty ? "Start learning to build your wordbank!" : "No words match your search."
        case .favorites:
            return "Favorite words will appear here when you mark them."
        case .mastered:
            return "Words you've mastered will appear here."
        case .learning:
            return "Words you're currently learning will appear here."
        }
    }
    
    private func loadTerms() async {
        isLoading = true
        
        // Simulate API call - replace with actual implementation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Mock data for preview
            terms = []
            isLoading = false
        }
    }
}

struct WordbankTermCard: View {
    let term: Term
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(term.word)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    if let partOfSpeech = term.partOfSpeech {
                        Text(partOfSpeech.abbreviation)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray5))
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    if term.isFavorite {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    if term.isMastered {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                    
                    Circle()
                        .fill(colorForDifficulty(term.difficulty))
                        .frame(width: 8, height: 8)
                }
            }
            
            // Definition
            Text(term.definition)
                .font(.body)
                .lineLimit(isExpanded ? nil : 2)
            
            // Progress info
            HStack {
                Text("Studied \(term.timesStudied) times")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if term.timesStudied > 0 {
                    let accuracy = Double(term.timesCorrect) / Double(term.timesStudied)
                    Text("\(Int(accuracy * 100))% accuracy")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Button(isExpanded ? "Less" : "More") {
                    withAnimation(.easeInOut) {
                        isExpanded.toggle()
                    }
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            // Additional info when expanded
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    if let examples = term.examples, !examples.isEmpty {
                        Text("Examples:")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        ForEach(examples.prefix(2), id: \.self) { example in
                            Text("• \(example)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let lastStudied = term.lastStudiedAt {
                        Text("Last studied: \(lastStudied, style: .relative) ago")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func colorForDifficulty(_ difficulty: DifficultyLevel) -> Color {
        switch difficulty {
        case .beginner:
            return .green
        case .intermediate:
            return .yellow
        case .advanced:
            return .orange
        case .expert:
            return .red
        }
    }
}

#Preview {
    WordbankView()
        .environmentObject(APIService())
}
