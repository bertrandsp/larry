//
//  larry_iosApp.swift
//  larry-ios
//
//  Created by Bertrand Saint-Preux on 9/14/25.
//

import SwiftUI
// import GoogleSignIn // TODO: Add GoogleSignIn dependency to Xcode project

@main
struct LarryApp: App {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authManager)
                .onOpenURL { url in
                    // Handle Google Sign-In URL callback
                    // TODO: Uncomment when GoogleSignIn dependency is added
                    // GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
