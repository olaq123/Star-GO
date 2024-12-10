import SwiftUI

struct SpaceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(SpaceTheme.accent)
            )
            .foregroundColor(SpaceTheme.background)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
} 