import SwiftUI

struct FleetView: View {
    @StateObject private var viewModel = FleetViewModel()
    
    var body: some View {
        VStack {
            Text("Fleet Management")
                .font(SpaceTheme.titleFont)
                .foregroundColor(SpaceTheme.foreground)
            
            Text("Coming Soon")
                .font(SpaceTheme.bodyFont)
                .foregroundColor(SpaceTheme.foreground.opacity(0.7))
        }
    }
}

class FleetViewModel: ObservableObject {
    // Add view model implementation later
} 