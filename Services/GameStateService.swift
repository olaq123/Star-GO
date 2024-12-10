import FirebaseFirestore

@MainActor
class GameStateService {
    private let db = Firestore.firestore()
    
    func saveGameState(_ state: GameState, for userId: String) async throws {
        let data = try JSONEncoder().encode(state)
        let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        
        try await db.collection("gameStates").document(userId).setData(dictionary)
    }
    
    func loadGameState(for userId: String) async throws -> GameState {
        let document = try await db.collection("gameStates").document(userId).getDocument()
        
        guard let data = document.data(),
              let jsonData = try? JSONSerialization.data(withJSONObject: data),
              let gameState = try? JSONDecoder().decode(AppGameState.self, from: jsonData) else {
            throw GameError.loadFailed
        }
        
        return gameState
    }
} 