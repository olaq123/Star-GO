import SwiftUI

@MainActor
class BuildingsViewModel: ObservableObject {
    @Published var planet: Planet
    @Published var showError = false
    @Published var errorMessage = ""
    
    init(planet: Planet) {
        self.planet = planet
    }
    
    func startConstruction(_ type: BuildingType) {
        do {
            try planet.startConstruction(
                type: type,
                currentTick: GameTime.shared.getCurrentTick()
            )
            objectWillChange.send()
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
    }
    
    func upgradeBuilding(_ building: Building) {
        do {
            try planet.upgradeBuilding(building)
            objectWillChange.send()
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
    }
    
    func canBuildNewBuilding(_ type: BuildingType) -> Bool {
        planet.canBuildNewBuilding(type)
    }
    
    func canUpgradeBuilding(_ building: Building) -> Bool {
        planet.canUpgradeBuilding(building)
    }
    
    func getTimeRemaining(_ type: BuildingType) -> Int? {
        if let construction = planet.constructionQueue.first(where: { $0.building.type == type }) {
            return construction.completionTick - GameTime.shared.getCurrentTick()
        }
        return nil
    }
} 