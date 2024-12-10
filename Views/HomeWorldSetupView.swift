import SwiftUI

struct HomeWorldSetupView: View {
    @StateObject private var locationManager = LocationManager.shared
    @State private var address = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            StarsBackgroundView()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "globe")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.blue)
                    
                    Text("Establish Your Home Base")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Enter your address to establish your home planet")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                // Address Input
                CustomTextField(
                    text: $address,
                    placeholder: "Enter your address",
                    imageName: "house.fill"
                )
                .padding(.horizontal, 32)
                
                // Action Button
                Button(action: setupHomeworld) {
                    if locationManager.isSettingUpHomeworld {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Establish Base")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(address.isEmpty ? Color.blue.opacity(0.5) : Color.blue)
                .cornerRadius(8)
                .padding(.horizontal, 32)
                .disabled(address.isEmpty || locationManager.isSettingUpHomeworld)
                
                Spacer()
            }
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