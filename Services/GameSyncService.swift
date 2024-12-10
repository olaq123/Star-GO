import FirebaseFirestore
import FirebaseAuth
import Foundation

@MainActor
class GameSyncService {
    static let shared = GameSyncService()
    private let db = Firestore.firestore()
    private var stateListener: ListenerRegistration?
    private var resourceListener: ListenerRegistration?
    
    // References
    private var userStateRef: DocumentReference? {
        guard let userId = Auth.auth().currentUser?.uid else { return nil }
        return db.collection("gameStates").document(userId)
    }
    
    private var resourcesRef: DocumentReference? {
        guard let userId = Auth.auth().currentUser?.uid else { return nil }
        return db.collection("resources").document(userId)
    }
    
    // Start real-time sync
    func startSync() {
        setupStateListener()
        setupResourceListener()
    }
    
    // Stop sync
    nonisolated func stopSync() {
        DispatchQueue.main.async {
            self.stateListener?.remove()
            self.resourceListener?.remove()
        }
    }
    
    // Save game state
    func saveGameState(_ state: GameState) async throws {
        guard let ref = userStateRef else { throw GameError.notAuthenticated }
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(state)
        guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw GameError.saveFailed
        }
        
        try await ref.setData([
            "state": dictionary,
            "lastUpdated": FieldValue.serverTimestamp()
        ])
    }
    
    // Save resources (more frequent updates)
    func saveResources(_ resources: Resources, planetId: String) async throws {
        guard let ref = resourcesRef else { throw GameError.notAuthenticated }
        
        let data: [String: Any] = [
            "metal": resources.metal,
            "crystal": resources.crystal,
            "energy": resources.energy,
            "planetId": planetId,
            "lastUpdated": FieldValue.serverTimestamp()
        ]
        
        try await ref.setData(data)
    }
    
    // MARK: - Private Methods
    
    private func setupStateListener() {
        guard let ref = userStateRef else { return }
        
        stateListener = ref.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self,
                  let data = snapshot?.data(),
                  let stateData = data["state"] as? [String: Any],
                  let jsonData = try? JSONSerialization.data(withJSONObject: stateData),
                  let gameState = try? JSONDecoder().decode(AppGameState.self, from: jsonData) else {
                return
            }
            
            // Update game state
            Task {
                self.updateGameState(gameState)
            }
        }
    }
    
    private func setupResourceListener() {
        guard let ref = resourcesRef else { return }
        
        resourceListener = ref.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self,
                  let data = snapshot?.data(),
                  let planetId = data["planetId"] as? String else {
                return
            }
            
            let resources = Resources(
                metal: data["metal"] as? Double ?? 0,
                crystal: data["crystal"] as? Double ?? 0,
                energy: data["energy"] as? Double ?? 0
            )
            
            // Update resources
            Task {
                self.updateResources(resources, for: planetId)
            }
        }
    }
    
    private func updateGameState(_ state: AppGameState) {
        // Update the game manager with new state
        GameManager.shared.updateState(state)
    }
    
    private func updateResources(_ resources: Resources, for planetId: String) {
        // Update the game manager with new resources
        GameManager.shared.updateResources(resources, for: planetId)
    }
    
    // Change this to internal or public
    func syncWithServer() async {
        // This will be implemented when server functionality is added
        print("Server sync not yet implemented")
    }
} 