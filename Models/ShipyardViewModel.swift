import SwiftUI

@MainActor
class ShipyardViewModel: ObservableObject {
    @Published var planet: Planet
    @Published var showError = false
    @Published var errorMessage = ""
    private var updateTimer: Timer?
    
    init(planet: Planet) {
        self.planet = planet
        setupTimer()
    }
    
    private func setupTimer() {
        // Update every second to check construction status
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkConstructionStatus()
            }
        }
    }
    
    private func checkConstructionStatus() {
        // Force view update when construction completes
        if !planet.fleet.isConstructing {
            objectWillChange.send()
        }
    }
    
    func buildShip(_ type: ShipType) {
        do {
            try planet.buildShip(type)
            objectWillChange.send()
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
    }
    
    func canBuildShip(_ type: ShipType) -> Bool {
        planet.canBuildShip(type)
    }
    
    func getTimeRemaining(_ type: ShipType) -> Int? {
        planet.fleet.getConstructionTimeRemaining(type)
    }
    
    func isShipUnlocked(_ type: ShipType) -> Bool {
        // Check if all required research is completed
        return type.requiredResearch.allSatisfy { researchType in
            planet.researchSystem.isResearched(researchType)
        }
    }
    
    deinit {
        updateTimer?.invalidate()
    }
} 