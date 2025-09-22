import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                LoadingView()
            } else if authManager.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .task {
            await checkAuthenticationState()
        }
    }
    
    private func checkAuthenticationState() async {
        await authManager.checkAuthenticationState()
        isLoading = false
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager())
        .environmentObject(APIService())
}
