import SwiftUI

struct PlanetBuildingCard: View {
    let type: BuildingType
    let level: Int
    let isUpgrading: Bool
    let canBuild: Bool
    let timeRemaining: Int?
    let onBuild: () -> Void
    let onUpgrade: () -> Void
    
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
                        
                        if level > 0 {
                            Text("Level \(level)")
                                .font(.system(size: 12))
                                .foregroundColor(SpaceTheme.foreground.opacity(0.7))
                        }
                    }
                    
                    Spacer()
                }
                
                // Description for new buildings
                if level == 0 {
                    Text(getBuildingDescription(type))
                        .font(.system(size: 12))
                        .foregroundColor(SpaceTheme.foreground.opacity(0.7))
                        .padding(.vertical, 4)
                }
                
                Divider()
                    .background(SpaceTheme.accent.opacity(0.3))
                
                // Action Section
                HStack {
                    // Costs
                    if level == 0 {
                        BuildCosts(costs: type.buildCost)
                    } else {
                        BuildCosts(costs: type.upgradeCost(forLevel: level))
                    }
                    
                    Spacer()
                    
                    // Build/Upgrade Button or Progress
                    if let remaining = timeRemaining {
                        ConstructionProgressView(timeRemaining: remaining)
                    } else if level == 0 {
                        Button(action: onBuild) {
                            Text("Build")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .buttonStyle(SpaceButtonStyle())
                        .disabled(!canBuild)
                    } else if isUpgrading {
                        ProgressView()
                            .tint(SpaceTheme.accent)
                    } else {
                        Button(action: onUpgrade) {
                            Text("Upgrade")
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
    
    private func getBuildingDescription(_ type: BuildingType) -> String {
        return type.description
    }
}
