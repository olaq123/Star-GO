import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var error: Error?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private let scanCooldown: TimeInterval = 300 // 5 minutes between scans
    private var lastScanTime: Date?
    
    @Published var isSettingUpHomeworld = false
    @Published var setupComplete = false
    
    internal override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.pausesLocationUpdatesAutomatically = true
        
        // Check initial authorization status
        authorizationStatus = locationManager.authorizationStatus
        
        // If already authorized, start updates
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            startUpdating()
        }
    }
    
    func requestPermission() {
        print("Requesting location permission...")
        // Check current status first
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdating()
        case .denied, .restricted:
            error = NSError(domain: "LocationManager", 
                          code: 2, 
                          userInfo: [NSLocalizedDescriptionKey: "Location access denied"])
        @unknown default:
            break
        }
    }
    
    func startUpdating() {
        print("Starting location updates...")
        
        // Check authorization status first
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if CLLocationManager.locationServicesEnabled() {
                DispatchQueue.global().async { [weak self] in
                    self?.locationManager.startUpdatingLocation()
                }
            } else {
                print("Location services are disabled")
                error = NSError(domain: "LocationManager", 
                              code: 1, 
                              userInfo: [NSLocalizedDescriptionKey: "Location services are disabled"])
            }
        case .notDetermined:
            requestPermission()
        case .denied, .restricted:
            error = NSError(domain: "LocationManager", 
                           code: 2, 
                           userInfo: [NSLocalizedDescriptionKey: "Location access denied"])
        @unknown default:
            break
        }
    }
    
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }
    
    func scanForPlanets() async {
        guard let currentLocation = location else { return }
        
        // Check cooldown
        if let lastScan = lastScanTime,
           Date().timeIntervalSince(lastScan) < scanCooldown {
            return
        }
        
        let gameLocation = Location(coordinate: currentLocation.coordinate)
        let newPlanets = await PlanetGenerator.shared.scanArea(around: gameLocation)
        
        // Add discovered planets to game state
        for planet in newPlanets {
            await GameManager.shared.addPlanet(planet)
        }
        
        lastScanTime = Date()
    }
    
    func setupHomeworld(at address: String) async throws {
        isSettingUpHomeworld = true
        defer { isSettingUpHomeworld = false }
        
        // Convert address to coordinates
        let geocoder = CLGeocoder()
        guard let placemarks = try? await geocoder.geocodeAddressString(address),
              let location = placemarks.first?.location else {
            throw GameError.invalidLocation
        }
        
        // Create home planet at location
        let gameLocation = Location(coordinate: location.coordinate)
        let homePlanet = await PlanetGenerator.shared.createHomePlanet(at: gameLocation)
        
        // Save to server
        try await FirestoreService.shared.savePlanet(homePlanet)
        
        // Update game state
        await GameManager.shared.setHomePlanet(homePlanet)
        
        setupComplete = true
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.authorizationStatus = manager.authorizationStatus
            print("Location authorization status changed to: \(self.authorizationStatus.rawValue)")
            
            switch self.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                print("Location access granted, starting updates...")
                self.startUpdating()
            case .denied, .restricted:
                print("Location access denied or restricted")
                self.error = NSError(domain: "LocationManager", 
                                   code: 2, 
                                   userInfo: [NSLocalizedDescriptionKey: "Location access denied"])
            case .notDetermined:
                print("Location authorization not determined")
                self.requestPermission()
            @unknown default:
                break
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let location = locations.last else { return }
            print("Location updated: \(location.coordinate)")
            
            // Update the published location
            self.location = location
            
            // Generate planets based on new location
            Task {
                let gameLocation = Location(
                    coordinate: CLLocationCoordinate2D(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    )
                )
                
                // Generate a new planet if none are nearby
                if let planet = await PlanetGenerator.shared.generatePlanet(near: gameLocation) {
                    GameManager.shared.addPlanet(planet)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            print("Location manager failed with error: \(error.localizedDescription)")
            self?.error = error
        }
    }
} 