import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab - Daily Word
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            // Larry Chat Tab
            ChatView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chat")
                }
                .tag(1)
            
            // Wordbank Tab
            WordbankView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Wordbank")
                }
                .tag(2)
            
            // Interests Tab
            InterestsView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Interests")
                }
                .tag(3)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(.primary)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationManager())
        .environmentObject(APIService())
}
