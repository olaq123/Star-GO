import SwiftUI

struct BuildingsView: View {
    @StateObject var viewModel: BuildingsViewModel
    
    init(planet: Planet) {
        _viewModel = StateObject(wrappedValue: BuildingsViewModel(planet: planet))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(BuildingType.allCases, id: \.self) { type in
                    let building = viewModel.planet.buildings.first { $0.type == type }
                    PlanetBuildingCard(
                        type: type,
                        level: building?.level ?? 0,
                        isUpgrading: building?.upgradeInProgress ?? false,
                        canBuild: viewModel.canBuildNewBuilding(type),
                        timeRemaining: viewModel.getTimeRemaining(type),
                        onBuild: { viewModel.startConstruction(type) },
                        onUpgrade: {
                            if let building = building {
                                viewModel.upgradeBuilding(building)
                            }
                        }
                    )
                }
            }
            .padding()
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

#if DEBUG
struct BuildingsView_Previews: PreviewProvider {
    static var previews: some View {
        BuildingsView(planet: Planet(name: "Test Planet"))
            .preferredColorScheme(.dark)
    }
}
#endif
 