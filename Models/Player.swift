import Foundation

class Player: Codable {
    let id: UUID
    var name: String
    var homePlanet: Planet
    var discoveredPlanets: Set<UUID> = []
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
        self.homePlanet = Planet(name: "\(name)'s Home")
        self.homePlanet.owner = self
        setupHomePlanet()
    }
    
    private func setupHomePlanet() {
        // Give starting resources
        homePlanet.resources = Resources(
            metal: 500,
            crystal: 300,
            energy: 100
        )
        
        // Add command center
        let commandCenter = Building(type: .commandCenter)
        homePlanet.buildings.append(commandCenter)
        
        // Add basic mine
        let mine = Building(type: .mine)
        homePlanet.buildings.append(mine)
        
        // Add basic power plant
        let powerPlant = Building(type: .powerPlant)
        homePlanet.buildings.append(powerPlant)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, homePlanet, discoveredPlanets
    }
} 