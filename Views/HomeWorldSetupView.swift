import SwiftUI

struct HomeWorldSetupView: View {
    @StateObject private var locationManager = LocationManager.shared
    @State private var address = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            StarsBackgroundView()
            
            VStack(spacing: 20) {
                Text("Establish Your Home Base")
                    .font(.title)
                    .foregroundColor(SpaceTheme.foreground)
                
                Text("Enter your address to establish your home planet")
                    .foregroundColor(SpaceTheme.foreground.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextField("Enter your address", text: $address)
                    .textFieldStyle(SpaceTextFieldStyle())
                    .padding()
                
                Button {
                    setupHomeworld()
                } label: {
                    if locationManager.isSettingUpHomeworld {
                        ProgressView()
                            .tint(SpaceTheme.foreground)
                    } else {
                        Text("Establish Base")
                            .font(.headline)
                    }
                }
                .buttonStyle(SpaceButtonStyle())
                .disabled(address.isEmpty || locationManager.isSettingUpHomeworld)
            }
            .padding()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func setupHomeworld() {
        Task {
            do {
                try await locationManager.setupHomeworld(at: address)
            } catch {
                showError = true
                errorMessage = error.localizedDescription
            }
        }
    }
} 