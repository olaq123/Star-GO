import SwiftUI
import Foundation

// Single source of truth for game state
final class AppGameState: ObservableObject, GameState, Decodable {
    private let queue = DispatchQueue(label: "com.stargo.gamestate")
    
    @Published var currentPlayer: Player?
    @Published var planets: [Planet] = []
    
    nonisolated func merge(with state: GameState) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            // Update planets
            for incomingPlanet in state.planets {
                if let existingIndex = self.planets.firstIndex(where: { $0.id == incomingPlanet.id }) {
                    // Update existing planet
                    self.planets[existingIndex] = incomingPlanet
                } else {
                    // Add new planet
                    self.planets.append(incomingPlanet)
                }
            }
            
            // Update player if needed
            if let incomingPlayer = state.currentPlayer {
                if self.currentPlayer == nil {
                    self.currentPlayer = incomingPlayer
                } else {
                    // Update player properties
                    self.currentPlayer?.homePlanet = incomingPlayer.homePlanet
                }
            }
            
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    nonisolated func hasPlanetNearby(_ location: Location, within distance: Double) -> Bool {
        queue.sync {
            planets.contains { planet in
                guard let planetLocation = planet.location else { return false }
                return planetLocation.distance(to: location) <= distance
            }
        }
    }
    
    // Codable conformance
    enum CodingKeys: String, CodingKey {
        case currentPlayer, planets
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currentPlayer = try container.decodeIfPresent(Player.self, forKey: .currentPlayer)
        planets = try container.decode([Planet].self, forKey: .planets)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(currentPlayer, forKey: .currentPlayer)
        try container.encode(planets, forKey: .planets)
    }
    
    init() {
        self.currentPlayer = nil
        self.planets = []
    }
    
    // Thread-safe methods to modify state
    func addPlanet(_ planet: Planet) {
        queue.async { [weak self] in
            self?.planets.append(planet)
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }
    }
    
    func setCurrentPlayer(_ player: Player) {
        queue.async { [weak self] in
            self?.currentPlayer = player
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }
    }
} 