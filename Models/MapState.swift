import Foundation
import CoreLocation

class MapState {
    static let shared = MapState()
    
    // Current map center and zoom level
    var centerCoordinate: CLLocationCoordinate2D
    var zoomLevel: Double
    
    // Selected planet (if any)
    var selectedPlanet: Planet?
    
    // View mode
    enum ViewMode {
        case global    // Shows all discovered planets
        case local     // Shows nearby planets only
    }
    var currentViewMode: ViewMode = .global
    
    private init() {
        // Start with a default location (can be updated to player's location)
        centerCoordinate = CLLocationCoordinate2D(latitude: 55.676098, longitude: 12.568337)
        zoomLevel = 15.0
    }
    
    func setViewMode(_ mode: ViewMode) {
        currentViewMode = mode
        NotificationCenter.default.post(name: .mapViewModeChanged, object: nil)
    }
    
    func selectPlanet(_ planet: Planet?) {
        selectedPlanet = planet
        NotificationCenter.default.post(
            name: .planetSelected,
            object: nil,
            userInfo: ["planet": planet as Any]
        )
    }
}

extension Notification.Name {
    static let mapViewModeChanged = Notification.Name("mapViewModeChanged")
    static let planetSelected = Notification.Name("planetSelected")
} 