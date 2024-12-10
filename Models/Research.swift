import Foundation

// MARK: - Research Types and Protocols
protocol ResearchProtocol {
    var displayName: String { get }
    var iconName: String { get }
    var description: String { get }
    var cost: Resources { get }
    var researchTime: Int { get }
    var prerequisites: [Research.ResearchType] { get }
    var bonusEffect: Double { get }
}

typealias GameResearchType = Research.ResearchType

// MARK: - Research Implementation
enum Research {
    enum ResearchType: String, Codable, CaseIterable, ResearchProtocol {
        case improvedMining
        case advancedPowerSystems
        case enhancedShipHulls
        case weaponSystems
        case shieldTechnology
        case advancedPropulsion
        
        var displayName: String {
            switch self {
            case .improvedMining: return "Improved Mining"
            case .advancedPowerSystems: return "Advanced Power Systems"
            case .enhancedShipHulls: return "Enhanced Ship Hulls"
            case .weaponSystems: return "Weapon Systems"
            case .shieldTechnology: return "Shield Technology"
            case .advancedPropulsion: return "Advanced Propulsion"
            }
        }
        
        var iconName: String {
            switch self {
            case .improvedMining: return "pickaxe.circle.fill"
            case .advancedPowerSystems: return "bolt.circle.fill"
            case .enhancedShipHulls: return "shield.circle.fill"
            case .weaponSystems: return "burst.circle.fill"
            case .shieldTechnology: return "shield.lefthalf.filled"
            case .advancedPropulsion: return "airplane.circle.fill"
            }
        }
        
        var description: String {
            switch self {
            case .improvedMining:
                return "Increases mining efficiency"
            case .advancedPowerSystems:
                return "Improves energy production"
            case .enhancedShipHulls:
                return "Stronger ship construction"
            case .weaponSystems:
                return "More powerful weapons"
            case .shieldTechnology:
                return "Better defensive shields"
            case .advancedPropulsion:
                return "Faster ship movement"
            }
        }
        
        var cost: Resources {
            switch self {
            case .improvedMining:
                return Resources(metal: 1000, crystal: 500, energy: 200)
            case .advancedPowerSystems:
                return Resources(metal: 800, crystal: 1000, energy: 300)
            case .enhancedShipHulls:
                return Resources(metal: 1500, crystal: 800, energy: 400)
            case .weaponSystems:
                return Resources(metal: 2000, crystal: 1500, energy: 500)
            case .shieldTechnology:
                return Resources(metal: 1800, crystal: 2000, energy: 600)
            case .advancedPropulsion:
                return Resources(metal: 1200, crystal: 1800, energy: 400)
            }
        }
        
        var researchTime: Int {
            return 1  // 1 tick for all research
        }
        
        var prerequisites: [Research.ResearchType] {
            switch self {
            case .improvedMining:
                return []
            case .advancedPowerSystems:
                return []
            case .enhancedShipHulls:
                return [.improvedMining]
            case .weaponSystems:
                return [.advancedPowerSystems]
            case .shieldTechnology:
                return [.advancedPowerSystems, .enhancedShipHulls]
            case .advancedPropulsion:
                return [.enhancedShipHulls]
            }
        }
        
        var bonusEffect: Double {
            switch self {
            case .improvedMining: return 0.25
            case .advancedPowerSystems: return 0.30
            case .enhancedShipHulls: return 0.40
            case .weaponSystems: return 0.35
            case .shieldTechnology: return 0.45
            case .advancedPropulsion: return 0.20
            }
        }
    }
} 