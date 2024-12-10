import SwiftUI

struct ResearchDashboardView: View {
    @StateObject private var viewModel: ResearchDashboardViewModel
    let planet: Planet
    
    init(planet: Planet) {
        self.planet = planet
        _viewModel = StateObject(wrappedValue: ResearchDashboardViewModel(planet: planet))
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 16) {
                // Research Categories
                ForEach(Research.ResearchType.allCases.chunked(into: 2), id: \.self) { row in
                    HStack(spacing: 16) {
                        ForEach(row, id: \.self) { type in
                            ResearchCard(
                                type: type,
                                isResearched: viewModel.isResearched(type),
                                isAvailable: viewModel.isAvailable(type),
                                timeRemaining: viewModel.getTimeRemaining(type),
                                onResearch: { viewModel.startResearch(type) }
                            )
                        }
                    }
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

// Helper extension for chunking arrays
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
} 