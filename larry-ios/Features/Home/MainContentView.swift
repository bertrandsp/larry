import SwiftUI

struct MainContentView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab - Daily Words with Real-Time Updates
            NavigationView {
                DailyWordsView()
                    .environmentObject(viewModel)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                Task {
                                    await viewModel.refreshData()
                                }
                            }) {
                                Image(systemName: viewModel.isRefreshing ? "arrow.clockwise" : "arrow.clockwise")
                                    .rotationEffect(.degrees(viewModel.isRefreshing ? 360 : 0))
                                    .animation(
                                        viewModel.isRefreshing ? 
                                        Animation.linear(duration: 1).repeatForever(autoreverses: false) : 
                                        .default, 
                                        value: viewModel.isRefreshing
                                    )
                            }
                            .disabled(viewModel.isRefreshing)
                        }
                    }
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Daily Words")
            }
            .tag(0)
            
            // Larry Chat Tab
            NavigationView {
                LarryChatView()
            }
            .tabItem {
                Image(systemName: "message.fill")
                Text("Larry Chat")
            }
            .tag(1)
            
            // Wordbank Tab
            NavigationView {
                WordbankView()
            }
            .tabItem {
                Image(systemName: "book.fill")
                Text("Wordbank")
            }
            .tag(2)
            
            // Profile Tab
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(3)
        }
        .onAppear {
            Task {
                await viewModel.loadDailyWords()
                await viewModel.loadFirstDailyWord()
            }
        }
    }
}

#Preview {
    MainContentView()
        .environmentObject(AuthManager.shared)
}