import SwiftUI

struct SpaceCardView<Content: View>: View {
    let isInteractive: Bool
    let content: Content
    
    init(isInteractive: Bool = true, @ViewBuilder content: () -> Content) {
        self.isInteractive = isInteractive
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(SpaceTheme.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(SpaceTheme.accent.opacity(0.3), lineWidth: 1)
            )
            .opacity(isInteractive ? 1.0 : 0.7)
    }
} 