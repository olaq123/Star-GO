import Foundation

enum ShipType: String, Codable, CaseIterable {
    case lightFighter
    case heavyFighter
    case cruiser
    case battleship
    
    var displayName: String {
        switch self {
        case .lightFighter: return "Light Fighter"
        case .heavyFighter: return "Heavy Fighter"
        case .cruiser: return "Cruiser"
        case .battleship: return "Battleship"
        }
    }
    
    var requiredResearch: [Research.ResearchType] {
        switch self {
        case .lightFighter:
            return []  // Basic ship, no research needed
        case .heavyFighter:
            return [.enhancedShipHulls]
        case .cruiser:
            return [.enhancedShipHulls, .weaponSystems]
        case .battleship:
            return [.enhancedShipHulls, .weaponSystems, .shieldTechnology]
        }
    }
    
    var requirementsDescription: String {
        var requirements: [String] = []
        
        if requiredResearch.isEmpty {
            return "Basic ship - No requirements"
        }
        
        requirements.append("Required Research:")
        requiredResearch.forEach { research in
            requirements.append("• \(research.displayName)")
        }
        
        return requirements.joined(separator: "\n")
    }
    
    var iconName: String {
        switch self {
        case .lightFighter: return "airplane"
        case .heavyFighter: return "airplane.circle"
        case .cruiser: return "airplane.circle.fill"
        case .battleship: return "shield.airplane.fill"
        }
    }
    
    var buildCost: Resources {
        switch self {
        case .lightFighter:
            return Resources(metal: 3000, crystal: 1000, energy: 100)
        case .heavyFighter:
            return Resources(metal: 6000, crystal: 2000, energy: 200)
        case .cruiser:
            return Resources(metal: 12000, crystal: 4000, energy: 400)
        case .battleship:
            return Resources(metal: 24000, crystal: 8000, energy: 800)
        }
    }
    
    var shieldStrength: Double {
        switch self {
        case .lightFighter: return 100
        case .heavyFighter: return 200
        case .cruiser: return 400
        case .battleship: return 800
        }
    }
    
    var attackPower: Double {
        switch self {
        case .lightFighter: return 150
        case .heavyFighter: return 300
        case .cruiser: return 600
        case .battleship: return 1200
        }
    }
} 