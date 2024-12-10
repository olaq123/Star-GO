import SwiftUI

struct ConstructionProgressView: View {
    let timeRemaining: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ProgressView()
                .tint(SpaceTheme.accent)
            
            Text("\(timeRemaining) ticks")
                .font(.system(size: 12))
                .foregroundColor(SpaceTheme.foreground.opacity(0.7))
        }
    }
} 