import Foundation

enum ResourceType: String, CaseIterable {
    case metal
    case crystal
    case energy
    
    var displayName: String {
        switch self {
        case .metal: return "Metal"
        case .crystal: return "Crystal"
        case .energy: return "Energy"
        }
    }
    
    var iconName: String {
        switch self {
        case .metal: return "cube.fill"
        case .crystal: return "diamond.fill"
        case .energy: return "bolt.fill"
        }
    }
    
    var description: String {
        switch self {
        case .metal: return "Basic construction material"
        case .crystal: return "Advanced technology component"
        case .energy: return "Power for buildings and ships"
        }
    }
} 