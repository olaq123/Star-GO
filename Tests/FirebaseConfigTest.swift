import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct FirebaseConfigTest: View {
    @State private var testStatus: [(message: String, success: Bool)] = []
    @State private var isRunningTests = false
    
    var body: some View {
        ZStack {
            StarsBackgroundView()
            
            VStack(spacing: 20) {
                Text("Firebase Configuration Test")
                    .font(.title)
                    .foregroundColor(SpaceTheme.foreground)
                
                if isRunningTests {
                    ProgressView()
                        .tint(SpaceTheme.accent)
                } else {
                    Button("Run Tests") {
                        runTests()
                    }
                    .buttonStyle(SpaceButtonStyle())
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(testStatus, id: \.message) { status in
                            HStack {
                                Image(systemName: status.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(status.success ? .green : .red)
                                Text(status.message)
                                    .foregroundColor(SpaceTheme.foreground)
                            }
                        }
                    }
                    .padding()
                }
            }
            .padding()
        }
    }
    
    private func runTests() {
        isRunningTests = true
        testStatus.removeAll()
        
        Task {
            do {
                // Test Firebase connection
                let success = try await FirebaseConfig.shared.runConnectionTest()
                testStatus.append(("Firebase Connection", success))
                
                // Test offline mode
                await FirebaseConfig.shared.setOfflineMode(true)
                testStatus.append(("Set Offline Mode", true))
                
                await FirebaseConfig.shared.setOfflineMode(false)
                testStatus.append(("Restore Online Mode", true))
                
                // Test initial data setup
                try await FirebaseConfig.shared.initializeGameData()
                testStatus.append(("Game Data Initialization", true))
                
                isRunningTests = false
            } catch {
                isRunningTests = false
                testStatus.append(("Test failed with error", false))
            }
        }
    }
}

#if DEBUG
struct FirebaseConfigTest_Previews: PreviewProvider {
    static var previews: some View {
        FirebaseConfigTest()
    }
}
#endif