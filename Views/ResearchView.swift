import SwiftUI

struct ResearchView: View {
    @StateObject private var viewModel = ResearchViewModel()
    
    var body: some View {
        VStack {
            Text("Research Lab")
                .font(SpaceTheme.titleFont)
                .foregroundColor(SpaceTheme.foreground)
            
            Text("Coming Soon")
                .font(SpaceTheme.bodyFont)
                .foregroundColor(SpaceTheme.foreground.opacity(0.7))
        }
    }
}

class ResearchViewModel: ObservableObject {
    // Add view model implementation later
} 