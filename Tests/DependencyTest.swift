import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import FirebaseAnalytics
import GoogleSignIn
import GoogleSignInSwift

// Simple view to test imports
struct DependencyTestView: View {
    var body: some View {
        Text("Dependencies Test")
            .onAppear {
                print("🔥 Testing Firebase configuration...")
                if FirebaseApp.app() != nil {
                    print("✅ Firebase is configured")
                } else {
                    print("❌ Firebase is not configured")
                }
                
                print("🔑 Testing Google Sign-In configuration...")
                if GIDSignIn.sharedInstance.configuration != nil {
                    print("✅ Google Sign-In is configured")
                } else {
                    print("❌ Google Sign-In is not configured")
                }
            }
    }
} 