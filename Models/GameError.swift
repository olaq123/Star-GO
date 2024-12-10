import Foundation

enum GameError: Error {
    case saveFailed
    case loadFailed
    case insufficientResources
    case invalidOperation
    case notAuthenticated
    case authenticationFailed
    case userCancelled
    case invalidLocation
    case homeworldAlreadyExists
    
    var localizedDescription: String {
        switch self {
        case .saveFailed:
            return "Failed to save game data"
        case .loadFailed:
            return "Failed to load game data"
        case .insufficientResources:
            return "Insufficient resources"
        case .invalidOperation:
            return "Invalid operation"
        case .notAuthenticated:
            return "User not authenticated"
        case .authenticationFailed:
            return "Authentication failed"
        case .userCancelled:
            return "Authentication cancelled by user"
        case .invalidLocation:
            return "Could not find valid location from address"
        case .homeworldAlreadyExists:
            return "Home planet already established"
        }
    }
} 