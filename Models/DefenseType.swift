import Foundation

enum DefenseType: String, Codable, CaseIterable {
    case laserTurret
    case missileLauncher
    case plasmaCannon
    case shieldGenerator
    
    var maxHealth: Double {
        switch self {
        case .laserTurret: return 800
        case .missileLauncher: return 1000
        case .plasmaCannon: return 1200
        case .shieldGenerator: return 1500
        }
    }
    
    var shieldStrength: Double {
        switch self {
        case .laserTurret: return 100
        case .missileLauncher: return 150
        case .plasmaCannon: return 200
        case .shieldGenerator: return 500
        }
    }
    
    var weaponPower: Double {
        switch self {
        case .laserTurret: return 150
        case .missileLauncher: return 200
        case .plasmaCannon: return 300
        case .shieldGenerator: return 50
        }
    }
    
    var buildCost: Resources {
        switch self {
        case .laserTurret:
            return Resources(metal: 800, crystal: 400, energy: 100)
        case .missileLauncher:
            return Resources(metal: 1200, crystal: 600, energy: 150)
        case .plasmaCannon:
            return Resources(metal: 1500, crystal: 800, energy: 200)
        case .shieldGenerator:
            return Resources(metal: 2000, crystal: 1000, energy: 300)
        }
    }
    
    var buildTicks: Int {
        return 1  // 1 tick for all defenses
    }
    
    var displayName: String {
        switch self {
        case .laserTurret: return "Laser Turret"
        case .missileLauncher: return "Missile Launcher"
        case .plasmaCannon: return "Plasma Cannon"
        case .shieldGenerator: return "Shield Generator"
        }
    }
    
    var iconName: String {
        switch self {
        case .laserTurret: return "bolt.circle.fill"
        case .missileLauncher: return "arrow.up.circle.fill"
        case .plasmaCannon: return "burst.fill"
        case .shieldGenerator: return "shield.fill"
        }
    }
} 