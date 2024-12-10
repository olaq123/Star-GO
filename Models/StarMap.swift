import Foundation
import CoreLocation

class StarMap {
    static let shared = StarMap()
    
    // Placeholder data for testing
    private let dummyPlanetLocations: [(name: String, lat: Double, lon: Double)] = [
        ("Alpha Station", 55.676098, 12.568337),
        ("Beta Outpost", 55.683334, 12.571428),
        ("Gamma Base", 55.673219, 12.564446),
        // Add more dummy locations as needed
    ]
    
    private(set) var discoveredPlanets: [Planet] = []
    private var placeholderPlanets: [Planet] = []
    
    private init() {
        setupPlaceholderPlanets()
    }
    
    private func setupPlaceholderPlanets() {
        // Create some placeholder planets at fixed locations
        placeholderPlanets = dummyPlanetLocations.map { data in
            let planet = Planet(name: data.name)
            let location = Location(
                coordinate: CLLocationCoordinate2D(
                    latitude: data.lat,
                    longitude: data.lon
                )
            )
            planet.discover(at: location)
            return planet
        }
    }
    
    func getNearbyPlanets(to location: Location, radius: Double) -> [Planet] {
        // For now, return placeholder planets within radius
        return placeholderPlanets.filter { planet in
            guard let planetLocation = planet.location else { return false }
            return location.distance(to: planetLocation) <= radius
        }
    }
    
    func addDiscoveredPlanet(_ planet: Planet) {
        discoveredPlanets.append(planet)
        NotificationCenter.default.post(
            name: .starMapUpdated,
            object: nil,
            userInfo: ["planet": planet]
        )
    }
    
    // Placeholder method for future server sync
    func syncWithServer() {
        // This will be implemented when server functionality is added
        print("Server sync not yet implemented")
    }
    
    // Get all visible planets (discovered + placeholder)
    func getVisiblePlanets() -> [Planet] {
        return discoveredPlanets + placeholderPlanets
    }
    
    // Get planet at specific location (if any)
    func getPlanet(at location: Location, threshold: Double = 100) -> Planet? {
        return getVisiblePlanets().first { planet in
            guard let planetLocation = planet.location else { return false }
            return location.distance(to: planetLocation) <= threshold
        }
    }
}

extension Notification.Name {
    static let starMapUpdated = Notification.Name("starMapUpdated")
} 