import Foundation
import CoreLocation

@MainActor
class PlanetGenerator {
    static let shared = PlanetGenerator()
    private let nameGenerator = NameGenerator()
    private let maxPlanetsPerScan = 5
    private let scanRadiusKm = 10.0 // 10km = 1 light year
    
    private init() {}
    
    // Create initial home planet at player's location
    func createHomePlanet(at location: Location) -> Planet {
        let planet = Planet(name: "Home Base")
        planet.discover(at: location)
        planet.discoveryDate = Date() // Set creation date for protection period
        
        // Enhanced starting resources for home planet
        planet.resources = Resources(
            metal: 2000,
            crystal: 1000,
            energy: 500
        )
        
        // Add basic buildings
        let commandCenter = Building(type: .commandCenter)
        commandCenter.level = 2  // Start with level 2 command center
        
        let mine = Building(type: .mine)
        let powerPlant = Building(type: .powerPlant)
        
        planet.buildings = [commandCenter, mine, powerPlant]
        
        return planet
    }
    
    func scanArea(around location: Location) async -> [Planet] {
        do {
            // First check if any planets exist in this area from the server
            let existingPlanets = try await FirestoreService.shared.loadNearbyPlanets(
                location: location,
                radius: scanRadiusKm
            )
            
            if !existingPlanets.isEmpty {
                return existingPlanets
            }
            
            // If no planets exist, generate new ones
            var newPlanets: [Planet] = []
            let numberOfPlanets = Int.random(in: 1...maxPlanetsPerScan)
            
            for _ in 0..<numberOfPlanets {
                if let planet = await generatePlanet(near: location) {
                    // Save new planet to server
                    try await FirestoreService.shared.savePlanet(planet)
                    newPlanets.append(planet)
                }
            }
            
            return newPlanets
        } catch {
            print("Error scanning area: \(error.localizedDescription)")
            return []
        }
    }
    
    func generatePlanet(near location: Location) async -> Planet? {
        // Check if area is too crowded
        let gameState = GameManager.shared.gameState
        if gameState.hasPlanetNearby(location, within: 0.5) { // 0.5 light years minimum distance
            return nil
        }
        
        // Generate planet with random position
        let planetLocation = Location.random(around: location, radiusKm: scanRadiusKm)
        let planet = createRandomPlanet()
        planet.discover(at: planetLocation)
        
        return planet
    }
    
    private func createRandomPlanet() -> Planet {
        let planet = Planet(name: nameGenerator.generatePlanetName())
        
        // Random starting resources
        planet.resources = Resources(
            metal: Double.random(in: 500...2000),
            crystal: Double.random(in: 300...1500),
            energy: Double.random(in: 100...1000)
        )
        
        // Random starting buildings
        let buildingTypes: [BuildingType] = [.mine, .powerPlant]
        buildingTypes.forEach { type in
            let building = Building(type: type)
            building.level = Int.random(in: 1...3)
            planet.buildings.append(building)
        }
        
        return planet
    }
}

// Helper class for generating planet names
private class NameGenerator {
    private let prefixes = ["Alpha", "Beta", "Gamma", "Delta", "Nova", "Proxima", "Sirius"]
    private let suffixes = ["Prime", "Major", "Minor", "X", "Y", "Z"]
    
    func generatePlanetName() -> String {
        let prefix = prefixes.randomElement() ?? "Planet"
        let suffix = suffixes.randomElement() ?? "X"
        let number = String(format: "%03d", Int.random(in: 1...999))
        return "\(prefix) \(suffix)-\(number)"
    }
} 