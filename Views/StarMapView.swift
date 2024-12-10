import SwiftUI
import CoreLocation

struct StarMapView: View {
    @StateObject private var locationManager = LocationManager.shared
    @EnvironmentObject private var gameManager: GameManager
    @State private var nearbyPlanets: [Planet] = []
    @State private var showLocationError = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            StarsBackgroundView()
            
            // Content
            VStack {
                if let location = locationManager.location {
                    // Map content
                    Text("Current Location:")
                        .foregroundColor(.white)
                    Text("Lat: \(location.coordinate.latitude), Long: \(location.coordinate.longitude)")
                        .foregroundColor(.gray)
                    
                    // Display nearby planets
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(nearbyPlanets, id: \.id) { planet in
                                PlanetCard(planet: planet)
                            }
                        }
                        .padding()
                    }
                } else {
                    // Location not available
                    VStack {
                        Image(systemName: "location.slash.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.red)
                        Text("Location Services Required")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("Please enable location services to discover planets")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Enable Location") {
                            locationManager.requestPermission()
                        }
                        .buttonStyle(SpaceButtonStyle())
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            locationManager.startUpdating()
            updateNearbyPlanets()
        }
        .onDisappear {
            locationManager.stopUpdating()
        }
    }
    
    private func updateNearbyPlanets() {
        guard let location = locationManager.location else { return }
        
        let gameLocation = Location(
            coordinate: CLLocationCoordinate2D(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        )
        
        // Get planets within range
        nearbyPlanets = gameManager.gameState.planets.filter { planet in
            guard let planetLocation = planet.location else { return false }
            return planetLocation.distance(to: gameLocation) <= 0.01
        }
    }
}

struct PlanetCard: View {
    let planet: Planet
    
    var body: some View {
        SpaceCardView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(planet.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if planet.isProtected {
                        Image(systemName: "shield.fill")
                            .foregroundColor(SpaceTheme.accent)
                    }
                }
                
                if let location = planet.location {
                    Text("Lat: \(location.latitude), Long: \(location.longitude)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                if planet.isProtected, let timeRemaining = planet.protectionTimeRemaining {
                    Text("Protected for \(Int(timeRemaining / 86400)) more days")
                        .font(.caption)
                        .foregroundColor(SpaceTheme.accent)
                }
            }
            .padding()
        }
    }
}

#if DEBUG
struct StarMapView_Previews: PreviewProvider {
    static var previews: some View {
        StarMapView()
            .environmentObject(GameManager())
            .environmentObject(LocationManager())
            .preferredColorScheme(.dark)
    }
}
#endif 