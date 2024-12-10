import SwiftUI

struct PlanetShipCard: View {
    let type: ShipType
    let count: Int
    let canBuild: Bool
    let timeRemaining: Int?
    let onBuild: () -> Void
    let researchSystem: Research.System
    let hasShipyard: Bool
    
    private var isUnlocked: Bool {
        guard hasShipyard else { return false }
        return type.requiredResearch.allSatisfy { researchSystem.isResearched($0) }
    }
    
    var body: some View {
        SpaceCardView {
            VStack(alignment: .leading, spacing: 8) {
                // Header
                HStack {
                    Image(systemName: type.iconName)
                        .font(.system(size: 20))
                        .foregroundColor(isUnlocked ? SpaceTheme.accent : SpaceTheme.foreground.opacity(0.5))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(type.displayName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(isUnlocked ? SpaceTheme.foreground : SpaceTheme.foreground.opacity(0.5))
                        
                        if !isUnlocked {
                            if !hasShipyard {
                                Text("Requires Shipyard")
                                    .font(.system(size: 12))
                                    .foregroundColor(SpaceTheme.warning)
                            } else {
                                Text(type.requirementsDescription)
                                    .font(.system(size: 12))
                                    .foregroundColor(SpaceTheme.warning)
                            }
                        } else {
                            Text("Count: \(count)")
                                .font(.system(size: 12))
                                .foregroundColor(SpaceTheme.foreground.opacity(0.7))
                        }
                    }
                    
                    Spacer()
                }
                
                // Stats
                HStack(spacing: 16) {
                    StatBadge(icon: "shield.fill", 
                             value: Int(type.shieldStrength), 
                             label: "Shield")
                    StatBadge(icon: "burst.fill", 
                             value: Int(type.attackPower), 
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
                        .disabled(!canBuild)
                    }
                }
            }
            .padding(12)
            .opacity(isUnlocked ? 1.0 : 0.7)
        }
    }
} 