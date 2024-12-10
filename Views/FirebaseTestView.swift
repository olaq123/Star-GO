import SwiftUI
import FirebaseFirestore

struct FirebaseTestView: View {
    @State private var testStatus: String = "Not tested"
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Firebase Connection Test")
                .font(.title)
            
            Text(testStatus)
                .foregroundColor(testStatus == "Success" ? .green : 
                               testStatus == "Failed" ? .red : .primary)
            
            Button(action: {
                Task {
                    await testConnection()
                }
            }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text("Test Connection")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .disabled(isLoading)
        }
        .padding()
    }
    
    private func testConnection() async {
        isLoading = true
        testStatus = "Testing..."
        
        do {
            try await FirebaseConfig.shared.testConnection()
            testStatus = "Success"
        } catch {
            testStatus = "Failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

#Preview {
    FirebaseTestView()
}
