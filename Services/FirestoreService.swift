import FirebaseFirestore
import FirebaseAuth

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    // Collection references with standard naming
    private var usersRef: CollectionReference { db.collection("users") }
    private var planetsRef: CollectionReference { db.collection("planets") }
    private var gameStatesRef: CollectionReference { db.collection("gameStates") }
    private var researchRef: CollectionReference { db.collection("research") }
    private var fleetsRef: CollectionReference { db.collection("fleets") }
    
    // MARK: - User Data
    func saveUser(_ user: User, username: String) async throws {
        let userData: [String: Any] = [
            "username": username,
            "email": user.email ?? "",
            "createdAt": FieldValue.serverTimestamp(),
            "lastLogin": FieldValue.serverTimestamp()
        ]
        
        try await usersRef.document(user.uid).setData(userData)
    }
    
    // MARK: - Game State
    func saveGameState(userId: String, gameState: GameState) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(gameState)
        
        guard let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw GameError.saveFailed
        }
        
        try await gameStatesRef.document(userId).setData([
            "state": dictionary,
            "lastUpdated": FieldValue.serverTimestamp()
        ])
    }
    
    func loadGameState(userId: String) async throws -> AppGameState {
        let document = try await gameStatesRef.document(userId).getDocument()
        
        guard let data = document.data(),
              let stateData = data["state"] as? [String: Any],
              let jsonData = try? JSONSerialization.data(withJSONObject: stateData),
              let gameState = try? JSONDecoder().decode(AppGameState.self, from: jsonData) else {
            throw GameError.loadFailed
        }
        
        return gameState
    }
    
    // MARK: - Planets
    func savePlanet(_ planet: Planet) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(planet)
        
        guard let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw GameError.saveFailed
        }
        
        // Add metadata for queries
        var planetData = dictionary
        planetData["creationDate"] = FieldValue.serverTimestamp()
        planetData["location"] = GeoPoint(
            latitude: planet.location?.latitude ?? 0,
            longitude: planet.location?.longitude ?? 0
        )
        
        try await planetsRef.document(planet.id.uuidString).setData(planetData)
    }
    
    func loadNearbyPlanets(location: Location, radius: Double) async throws -> [Planet] {
        // Create a geohash range to query efficiently
        let center = GeoPoint(latitude: location.latitude, longitude: location.longitude)
        let bounds = GeoUtils.getBoundsForRadius(center: center, radiusKm: radius)
        
        // Use collection query for direct planet access
        let query = planetsRef
            .whereField("location.latitude", isGreaterThan: bounds.south)
            .whereField("location.latitude", isLessThan: bounds.north)
            .whereField("location.longitude", isGreaterThan: bounds.west)
            .whereField("location.longitude", isLessThan: bounds.east)
            .limit(to: 50)  // Limit results for performance
        
        let snapshot = try await query.getDocuments()
        return try snapshot.documents.compactMap { document in
            let data = document.data()
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            return try JSONDecoder().decode(Planet.self, from: jsonData)
        }
    }
    
    // Add method for querying all planets owned by a player
    func loadPlayerPlanets(userId: String) async throws -> [Planet] {
        // Use collection group query to find all planets owned by the player
        let query = db.collectionGroup("planets")
            .whereField("owner", isEqualTo: userId)
            .order(by: "creationDate", descending: true)
        
        let snapshot = try await query.getDocuments()
        return try snapshot.documents.compactMap { document in
            let data = document.data()
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            return try JSONDecoder().decode(Planet.self, from: jsonData)
        }
    }
    
    // MARK: - Real-time Updates
    func observePlanetUpdates(in radius: Double, around location: Location) -> ListenerRegistration {
        let center = GeoPoint(latitude: location.latitude, longitude: location.longitude)
        let bounds = GeoUtils.getBoundsForRadius(center: center, radiusKm: radius)
        
        return planetsRef
            .whereField("location.latitude", isGreaterThanOrEqualTo: bounds.south)
            .whereField("location.latitude", isLessThanOrEqualTo: bounds.north)
            .addSnapshotListener { querySnapshot, error in
                guard error == nil else {
                    print("Error observing planets: \(error!.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No planets found in range")
                    return
                }
                
                // Process the documents
                let planets = documents.compactMap { document -> Planet? in
                    try? document.data(as: Planet.self)
                }
                
                // Notify about planet updates
                NotificationCenter.default.post(
                    name: .planetsUpdated,
                    object: nil,
                    userInfo: ["planets": planets]
                )
            }
    }
}

// Helper struct for geospatial queries
private struct GeoUtils {
    static func getBoundsForRadius(center: GeoPoint, radiusKm: Double) -> (north: Double, south: Double, east: Double, west: Double) {
        // Earth's radius in kilometers
        let earthRadius = 6371.0
        
        // Angular distance in radians
        let radDist = radiusKm / earthRadius
        
        let radLat = center.latitude * .pi / 180
        let radLon = center.longitude * .pi / 180
        
        let minLat = radLat - radDist
        let maxLat = radLat + radDist
        
        let deltaLon = asin(sin(radDist) / cos(radLat))
        let minLon = radLon - deltaLon
        let maxLon = radLon + deltaLon
        
        return (
            north: maxLat * 180 / .pi,
            south: minLat * 180 / .pi,
            east: maxLon * 180 / .pi,
            west: minLon * 180 / .pi
        )
    }
} 