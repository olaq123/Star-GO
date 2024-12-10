import SwiftUI

struct ShipyardView: View {
    @StateObject var viewModel: ShipyardViewModel
    
    init(planet: Planet) {
        _viewModel = StateObject(wrappedValue: ShipyardViewModel(planet: planet))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(ShipType.allCases, id: \.self) { type in
                    ShipCardView(type: type, viewModel: viewModel)
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

// Separate view for ship card to reduce complexity
private struct ShipCardView: View {
    let type: ShipType
    let viewModel: ShipyardViewModel
    
    var body: some View {
        let shipCount = viewModel.planet.fleet.ships.filter { $0.type == type }.count
        let canBuild = viewModel.canBuildShip(type)
        let timeRemaining = viewModel.getTimeRemaining(type)
        let hasShipyard = viewModel.planet.buildings.contains { $0.type == .shipyard }
        
        PlanetShipCard(
            type: type,
            count: shipCount,
            canBuild: canBuild && viewModel.isShipUnlocked(type),
            timeRemaining: timeRemaining,
            onBuild: { viewModel.buildShip(type) },
            researchSystem: viewModel.planet.researchSystem,
            hasShipyard: hasShipyard
        )
    }
}

#if DEBUG
struct ShipyardView_Previews: PreviewProvider {
    static var previews: some View {
        ShipyardView(planet: Planet(name: "Test Planet"))
            .preferredColorScheme(.dark)
    }
}
#endif 