import SwiftUI

class DefensesViewModel: ObservableObject {
    @Published var planet: Planet
    @Published var showError = false
    @Published var errorMessage = ""
    
    init(planet: Planet) {
        self.planet = planet
    }
    
    func buildDefense(_ type: DefenseType) {
        do {
            try planet.buildDefense(type)
            objectWillChange.send()
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
    }
    
    func getDefenseCount(_ type: DefenseType) -> Int {
        planet.getDefenseCount(type)
    }
    
    func getDefenseLimit() -> Int {
        planet.getDefenseLimit()
    }
    
    func canBuildDefense(_ type: DefenseType) -> Bool {
        planet.canBuildDefense(type)
    }
    
    func getTimeRemaining(_ type: DefenseType) -> Int? {
        if let construction = planet.defenseConstructionQueue.first(where: { $0.defense.type == type }) {
            return construction.completionTick - GameTime.shared.getCurrentTick()
        }
        return nil
    }
} 