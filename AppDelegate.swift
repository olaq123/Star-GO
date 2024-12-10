//
//  AppDelegate.swift
//  Star GO
//
//  Created by Frederik Balsløw on 24/11/2024.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Configure Google Sign In
        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }
        
        return true
    }
    
    func application(_ app: UIApplication,
                    open url: URL,
                    options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        }
        return false
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Handle background state
        print("App entered background")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Handle foreground state
        print("App will enter foreground")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Handle app termination
    }
}
