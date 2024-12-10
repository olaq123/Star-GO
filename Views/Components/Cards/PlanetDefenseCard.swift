import SwiftUI

struct PlanetDefenseCard: View {
    let type: DefenseType
    let count: Int
    let limit: Int
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
                        
                        // Show count and limit
                        Text("\(count)/\(limit)")
                            .font(.system(size: 12))
                            .foregroundColor(count >= limit ? SpaceTheme.warning : SpaceTheme.foreground)
                    }
                    
                    Spacer()
                }
                
                // Stats
                HStack(spacing: 16) {
                    StatBadge(icon: "shield.fill", 
                             value: Int(type.shieldStrength), 
                             label: "Shield")
                    StatBadge(icon: "burst.fill", 
                             value: Int(type.weaponPower), 
                             label: "Attack")
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
                        .disabled(!canBuild || count >= limit)
                    }
                }
            }
            .padding(12)
        }
    }
}
 