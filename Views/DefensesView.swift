import SwiftUI

struct DefensesView: View {
    @StateObject var viewModel: DefensesViewModel
    
    init(planet: Planet) {
        _viewModel = StateObject(wrappedValue: DefensesViewModel(planet: planet))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(DefenseType.allCases, id: \.self) { type in
                    PlanetDefenseCard(
                        type: type,
                        count: viewModel.getDefenseCount(type),
                        limit: viewModel.getDefenseLimit(),
                        canBuild: viewModel.canBuildDefense(type),
                        timeRemaining: viewModel.getTimeRemaining(type),
                        onBuild: { viewModel.buildDefense(type) }
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
