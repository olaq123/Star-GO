import SwiftUI
import Foundation

class ResearchDashboardViewModel: ObservableObject {
    let planet: Planet
    @Published var showError = false
    @Published var errorMessage = ""
    
    init(planet: Planet) {
        self.planet = planet
    }
    
    func isResearched(_ type: Research.ResearchType) -> Bool {
        planet.researchSystem.isResearched(type)
    }
    
    func isResearching(_ type: Research.ResearchType) -> Bool {
        planet.researchSystem.isResearching(type)
    }
    
    func isAvailable(_ type: Research.ResearchType) -> Bool {
        planet.researchSystem.canResearch(type)
    }
    
    func startResearch(_ type: Research.ResearchType) {
        guard isAvailable(type) else {
            showError = true
            errorMessage = "Prerequisites not met"
            return
        }
        
        guard planet.resources.canAfford(type.cost) else {
            showError = true
            errorMessage = "Insufficient resources"
            return
        }
        
        do {
            try planet.resources.subtract(type.cost)
            planet.researchSystem.startResearch(type, currentTick: GameTime.shared.getCurrentTick())
            objectWillChange.send()
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
    }
    
    func getTimeRemaining(_ type: Research.ResearchType) -> Int? {
        planet.researchSystem.getResearchTimeRemaining(type)
    }
} 