import SwiftUI
import FirebaseCore

@main
struct StarGOApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var gameManager = GameManager.shared
    
    var body: some Scene {
        WindowGroup {
            #if DEBUG
            Group {
                if authViewModel.isAuthenticated {
                    MainGameView()
                        .environmentObject(authViewModel)
                        .environmentObject(gameManager)
                } else {
                    AuthenticationView()
                        .environmentObject(authViewModel)
                }
            }
            #else
            Group {
                if authViewModel.isAuthenticated {
                    MainGameView()
                        .environmentObject(authViewModel)
                        .environmentObject(gameManager)
                } else {
                    AuthenticationView()
                        .environmentObject(authViewModel)
                }
            }
            #endif
        }
    }
}