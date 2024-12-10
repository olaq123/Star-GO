import SwiftUI

struct DefenseBuildCard: View {
    let type: DefenseType
    let canBuild: Bool
    let timeRemaining: Int?
    let onBuild: () -> Void
    
    var body: some View {
        SpaceCardView {
            VStack(alignment: .leading, spacing: 8) {
                // Header
                HStack {
                    Image(systemName: type.iconName)
                        .font(.system(size: 20))
                        .foregroundColor(SpaceTheme.accent)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(type.displayName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(SpaceTheme.foreground)
                    }
                    
                    Spacer()
                }
                
                Divider()
                    .background(SpaceTheme.accent.opacity(0.3))
                
                // Action Section
                HStack {
                    BuildCosts(costs: type.buildCost)
                    
                    Spacer()
                    
                    if let remaining = timeRemaining {
                        ConstructionProgressView(timeRemaining: remaining)
                    } else {
                        Button(action: onBuild) {
                            Text("Build")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .buttonStyle(SpaceButtonStyle())
                        .disabled(!canBuild)
                    }
                }
            }
            .padding(12)
        }
    }
}
 