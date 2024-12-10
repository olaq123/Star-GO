//
//  AppDelegate.swift
//  Star GO
//
//  Created by Frederik Balsløw on 24/11/2024.
//

import UIKit
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        // Enable data collection
        FirebaseApp.app()?.isDataCollectionDefaultEnabled = true
        return true
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
