import SwiftUI

enum SpaceTheme {
    // Colors
    static let background = Color.black
    static let foreground = Color.white
    static let accent = Color("AccentBlue") // Deep blue with slight glow
    static let secondary = Color("SpaceGray") // Dark gray with slight transparency
    static let warning = Color("CosmicRed")
    static let success = Color("NebularGreen")
    
    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [Color("GradientStart"), Color("GradientEnd")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Text Styles
    static let titleFont = Font.custom("SpaceGrotesk-Bold", size: 24)
    static let bodyFont = Font.custom("SpaceGrotesk-Regular", size: 16)
    static let captionFont = Font.custom("SpaceGrotesk-Light", size: 14)
} 