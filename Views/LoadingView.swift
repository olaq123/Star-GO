import SwiftUI

struct LoadingView: View {
    @EnvironmentObject private var gameManager: GameManager
    @EnvironmentObject private var locationManager: LocationManager
    @State private var loadingProgress = 0.0
    @State private var rotation = 0.0
    @State private var loadingText = "Initializing Systems..."
    @State private var debugMessage = ""
    @State private var showLocationAlert = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            FixedStarsBackgroundView()
            
            VStack(spacing: 30) {
                // Logo
                ZStack {
                    Circle()
                        .fill(SpaceTheme.background)
                        .frame(width: 120, height: 120)
                        .overlay(
                            Circle()
                                .strokeBorder(SpaceTheme.accent, lineWidth: 3)
                        )
                    
                    Image(systemName: "star.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(SpaceTheme.accent)
                        .rotationEffect(.degrees(rotation))
                    
                    OrbitalRing(radius: 45, dotCount: 3)
                        .rotationEffect(.degrees(rotation * 0.5))
                }
                
                Text("Star GO")
                    .font(SpaceTheme.titleFont)
                    .foregroundColor(SpaceTheme.foreground)
                    .padding()
                
                Text(loadingText)
                    .font(SpaceTheme.captionFont)
                    .foregroundColor(SpaceTheme.foreground.opacity(0.7))
                
                ProgressView(value: loadingProgress)
                    .tint(SpaceTheme.accent)
                    .padding(.horizontal)
                
                // Debug info
                Text(debugMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            
            // Start initialization sequence
            initializeGame()
        }
        .alert("Location Access Required", isPresented: $showLocationAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable location services to play Star GO.")
        }
        .onChange(of: locationManager.authorizationStatus) { oldValue, newValue in
            debugMessage = "Location status changed to: \(newValue.rawValue)"
            if newValue == .denied || newValue == .restricted {
                showLocationAlert = true
            }
        }
    }
    
    private func initializeGame() {
        debugMessage = "Starting initialization..."
        
        // Request location permission immediately
        locationManager.requestPermission()
        
        // Define loading steps
        let loadingSteps = [
            (text: "Initializing Systems...", duration: 1.0),
            (text: "Requesting Location Access...", duration: 1.5),
            (text: "Scanning Nearby Space...", duration: 1.5),
            (text: "Establishing Command Center...", duration: 1.0)
        ]
        
        var totalTime: Double = 0
        
        // Execute each loading step
        for (index, step) in loadingSteps.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + totalTime) {
                loadingText = step.text
                debugMessage = "Step \(index + 1): \(step.text)"
                
                // Animate progress for this step
                withAnimation(.easeInOut(duration: step.duration)) {
                    loadingProgress = Double(index + 1) / Double(loadingSteps.count)
                }
                
                // On final step, complete initialization
                if index == loadingSteps.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + step.duration) {
                        Task { @MainActor in
                            debugMessage = "Starting location updates..."
                            // Start location updates
                            locationManager.startUpdating()
                            
                            debugMessage = "Initializing game state..."
                            // Initialize game state
                            gameManager.startNewGame()
                            
                            debugMessage = "Checking initialization status..."
                            // Check if everything is ready
                            if !gameManager.isInitialized {
                                debugMessage = "Error: Game manager not initialized"
                            }
                            if locationManager.location == nil {
                                debugMessage = "Error: Location not available"
                            }
                        }
                    }
                }
            }
            
            totalTime += step.duration
        }
    }
}

#if DEBUG
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
#endif 