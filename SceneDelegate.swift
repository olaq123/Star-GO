import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let authViewModel = AuthViewModel()
        let gameManager = GameManager.shared
        
        let rootView = Group {
            if authViewModel.isAuthenticated {
                MainGameView()
                    .environmentObject(authViewModel)
                    .environmentObject(gameManager)
            } else {
                AuthenticationView()
                    .environmentObject(authViewModel)
            }
        }
        
        window.rootViewController = UIHostingController(rootView: rootView)
        self.window = window
        window.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called when the scene is being released by the system
        print("Scene disconnected")
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state
        print("Scene became active")
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state
        print("Scene will resign active")
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background
        print("Scene entered background")
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground
        print("Scene will enter foreground")
    }
}
