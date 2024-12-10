import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class GameManager: ObservableObject {
    static let shared = GameManager()
    @Published private(set) var gameState: AppGameState
    @Published var isInitialized = false
    private var syncTimer: Timer?
    private var resourceUpdateTimer: Timer?
    private var gameUpdateTimer: Timer?
    private var planetListener: ListenerRegistration?
    private let gameSyncService = GameSyncService.shared
    
    init() {
        self.gameState = AppGameState()
        setupTimers()
        setupListeners()
    }
    
    private func setupTimers() {
        // Update resources every second
        resourceUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateResources()
            }
        }
        
        // Update game state every second
        gameUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateGame()
            }
        }
        
        // Sync with server every 5 seconds
        syncTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.syncWithServer()
            }
        }
    }
    
    private func setupListeners() {
        // Listen for real-time updates
        gameSyncService.startSync()
    }
    
    private func syncWithServer() async {
        do {
            // Save current state to server
            try await gameSyncService.saveGameState(gameState)
            
            // Save resources for each planet
            for planet in gameState.planets {
                try await gameSyncService.saveResources(
                    planet.resources,
                    planetId: planet.id.uuidString
                )
            }
        } catch {
            print("Failed to sync with server: \(error.localizedDescription)")
        }
    }
    
    func updateState(_ state: GameState) {
        // Merge incoming state with local state
        gameState.merge(with: state)
        objectWillChange.send()
    }
    
    func updateResources(_ resources: Resources, for planetId: String) {
        if let planet = gameState.planets.first(where: { $0.id.uuidString == planetId }) {
            planet.resources = resources
            objectWillChange.send()
        }
    }
    
    private func updateResources() {
        guard let planet = gameState.currentPlayer?.homePlanet else { return }
        let production = planet.calculateResourceProduction()
        
        // Add hourly production divided by 3600 (seconds in an hour)
        planet.resources.metal += production.metal / 3600
        planet.resources.crystal += production.crystal / 3600
        planet.resources.energy += production.energy / 3600
        
        objectWillChange.send()
    }
    
    private func updateGame() {
        let currentTick = GameTime.shared.getCurrentTick()
        if let planet = gameState.currentPlayer?.homePlanet {
            planet.update(tick: currentTick)
        }
        objectWillChange.send()
    }
    
    func addPlanet(_ planet: Planet) {
        gameState.addPlanet(planet)
        objectWillChange.send()
    }
    
    func setHomePlanet(_ planet: Planet) {
        if let player = gameState.currentPlayer {
            player.homePlanet = planet
            gameState.addPlanet(planet)
            objectWillChange.send()
        }
    }
    
    deinit {
        resourceUpdateTimer?.invalidate()
        gameUpdateTimer?.invalidate()
        syncTimer?.invalidate()
        gameSyncService.stopSync()
    }
    
    // ... rest of the implementation ...
    
    @MainActor
    func startNewGame() {
        // Create initial game state
        let newState = AppGameState()
        
        // Create player's home planet with a name
        let homePlanet = Planet(name: "Home Base")
        
        // Create player with a name
        let player = Player(name: "Player 1")
        player.homePlanet = homePlanet
        
        // Set up initial state
        newState.setCurrentPlayer(player)
        newState.addPlanet(homePlanet)
        
        // Update game state
        self.gameState = newState
        self.isInitialized = true
    }
} 