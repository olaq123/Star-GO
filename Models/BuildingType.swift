import Foundation

enum BuildingType: String, Codable, CaseIterable {
    case commandCenter
    case mine
    case powerPlant
    case shipyard
    case researchLab
    
    var displayName: String {
        switch self {
        case .commandCenter: return "Command Center"
        case .mine: return "Metal Mine"
        case .powerPlant: return "Power Plant"
        case .shipyard: return "Shipyard"
        case .researchLab: return "Research Lab"
        }
    }
    
    var iconName: String {
        switch self {
        case .commandCenter: return "building.columns.fill"
        case .mine: return "cube.fill"
        case .powerPlant: return "bolt.fill"
        case .shipyard: return "airplane.circle.fill"
        case .researchLab: return "atom"
        }
    }
    
    var description: String {
        switch self {
        case .commandCenter: return "Central control facility for your planet"
        case .mine: return "Produces metal for construction"
        case .powerPlant: return "Generates energy for your facilities"
        case .shipyard: return "Allows construction of ships"
        case .researchLab: return "Enables technological advancement"
        }
    }
    
    var buildCost: Resources {
        switch self {
        case .commandCenter:
            return Resources(metal: 1000, crystal: 500, energy: 0)
        case .mine:
            return Resources(metal: 500, crystal: 200, energy: 50)
        case .powerPlant:
            return Resources(metal: 300, crystal: 100, energy: 0)
        case .shipyard:
            return Resources(metal: 2000, crystal: 1000, energy: 200)
        case .researchLab:
            return Resources(metal: 1500, crystal: 1000, energy: 150)
        }
    }
    
    func upgradeCost(forLevel level: Int) -> Resources {
        let baseCost = buildCost
        let multiplier = pow(1.5, Double(level))
        return Resources(
            metal: baseCost.metal * multiplier,
            crystal: baseCost.crystal * multiplier,
            energy: baseCost.energy * multiplier
        )
    }
    
    var resourceProduction: Resources? {
        switch self {
        case .mine:
            return Resources(metal: 30, crystal: 0, energy: 0)
        case .powerPlant:
            return Resources(metal: 0, crystal: 0, energy: 40)
        default:
            return nil
        }
    }
    
    func productionAtLevel(_ level: Int) -> Resources? {
        guard let baseProduction = resourceProduction else { return nil }
        let multiplier = pow(1.1, Double(level))
        return Resources(
            metal: baseProduction.metal * multiplier,
            crystal: baseProduction.crystal * multiplier,
            energy: baseProduction.energy * multiplier
        )
    }
    
    var buildTime: Int {
        return 1  // 1 tick for all buildings
    }
} 