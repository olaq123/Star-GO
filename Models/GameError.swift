import Foundation

enum GameError: LocalizedError {
    case authenticationFailed
    case noRootViewController
    case invalidCredentials
    case saveFailed
    case loadFailed
    case insufficientResources
    case invalidOperation
    case notAuthenticated
    case userCancelled
    case invalidLocation
    case homeworldAlreadyExists
    
    var errorDescription: String? {
        switch self {
        case .authenticationFailed:
            return "Authentication failed. Please try again."
        case .noRootViewController:
            return "Could not find the root view controller."
        case .invalidCredentials:
            return "Invalid credentials provided."
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
        case .userCancelled:
            return "Authentication cancelled by user"
        case .invalidLocation:
            return "Could not find valid location from address"
        case .homeworldAlreadyExists:
            return "Home planet already established"
        }
    }
}