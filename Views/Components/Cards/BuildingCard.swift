import SwiftUI

struct BuildingCard: View {
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
                    Text(type.description)
                        .font(.system(size: 12))
                        .foregroundColor(SpaceTheme.foreground.opacity(0.7))
                        .padding(.vertical, 4)
                }
                
                // Current Production (if applicable)
                if let currentProduction = type.productionAtLevel(level) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Production:")
                            .font(.system(size: 12))
                            .foregroundColor(SpaceTheme.foreground.opacity(0.7))
                        
                        HStack(spacing: 16) {
                            if currentProduction.metal > 0 {
                                ProductionBadge(
                                    icon: "cube.fill",
                                    value: Int(currentProduction.metal),
                                    label: "Metal/h"
                                )
                            }
                            if currentProduction.crystal > 0 {
                                ProductionBadge(
                                    icon: "diamond.fill",
                                    value: Int(currentProduction.crystal),
                                    label: "Crystal/h"
                                )
                            }
                            if currentProduction.energy > 0 {
                                ProductionBadge(
                                    icon: "bolt.fill",
                                    value: Int(currentProduction.energy),
                                    label: "Energy/h"
                                )
                            }
                        }
                    }
                    
                    // Next Level Production Preview
                    if level > 0 {
                        let nextLevelProduction = type.productionAtLevel(level + 1)!
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Next Level Production:")
                                .font(.system(size: 12))
                                .foregroundColor(SpaceTheme.foreground.opacity(0.7))
                            
                            HStack(spacing: 16) {
                                if nextLevelProduction.metal > 0 {
                                    ProductionBadge(
                                        icon: "cube.fill",
                                        value: Int(nextLevelProduction.metal),
                                        label: "Metal/h"
                                    )
                                }
                                if nextLevelProduction.crystal > 0 {
                                    ProductionBadge(
                                        icon: "diamond.fill",
                                        value: Int(nextLevelProduction.crystal),
                                        label: "Crystal/h"
                                    )
                                }
                                if nextLevelProduction.energy > 0 {
                                    ProductionBadge(
                                        icon: "bolt.fill",
                                        value: Int(nextLevelProduction.energy),
                                        label: "Energy/h"
                                    )
                                }
                            }
                            
                            // Show production increase
                            let increase = nextLevelProduction.metal - currentProduction.metal
                            if increase > 0 {
                                Text("(+\(Int(increase))/h)")
                                    .font(.system(size: 10))
                                    .foregroundColor(SpaceTheme.success)
                            }
                        }
                    }
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
}

private struct ProductionBadge: View {
    let icon: String
    let value: Int
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text("+\(value)")
                .font(.system(size: 12, weight: .medium))
            Text(label)
                .font(.system(size: 10))
        }
        .foregroundColor(SpaceTheme.success)
    }
}

#if DEBUG
struct BuildingCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            BuildingCard(
                type: .mine,
                level: 0,
                isUpgrading: false,
                canBuild: true,
                timeRemaining: nil,
                onBuild: {},
                onUpgrade: {}
            )
            
            BuildingCard(
                type: .powerPlant,
                level: 2,
                isUpgrading: false,
                canBuild: true,
                timeRemaining: nil,
                onBuild: {},
                onUpgrade: {}
            )
        }
        .padding()
        .background(Color.black)
        .previewLayout(.sizeThatFits)
    }
}
#endif