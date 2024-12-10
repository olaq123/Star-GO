import SwiftUI

struct ResearchCard: View {
    let type: Research.ResearchType
    let isResearched: Bool
    let isAvailable: Bool
    let timeRemaining: Int?
    let onResearch: () -> Void
    
    var body: some View {
        SpaceCardView {
            VStack(alignment: .leading, spacing: 8) {
                // Header
                HStack {
                    Image(systemName: type.iconName)
                        .font(.system(size: 20))
                        .foregroundColor(isResearched ? SpaceTheme.success : SpaceTheme.accent)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(type.displayName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(SpaceTheme.foreground)
                        
                        Text(type.description)
                            .font(.system(size: 12))
                            .foregroundColor(SpaceTheme.foreground.opacity(0.7))
                    }
                    
                    Spacer()
                }
                
                // Bonus Effect
                HStack {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 12))
                    Text("+\(Int(type.bonusEffect * 100))%")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(SpaceTheme.success)
                .padding(.vertical, 4)
                
                // Prerequisites if not researched
                if !isResearched && !type.prerequisites.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Prerequisites:")
                            .font(.system(size: 12))
                            .foregroundColor(SpaceTheme.foreground.opacity(0.7))
                        
                        ForEach(type.prerequisites, id: \.self) { prereq in
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(isResearched ? SpaceTheme.success : SpaceTheme.warning)
                                
                                Text(prereq.displayName)
                                    .font(.system(size: 12))
                                    .foregroundColor(SpaceTheme.foreground.opacity(0.7))
                            }
                        }
                    }
                }
                
                Divider()
                    .background(SpaceTheme.accent.opacity(0.3))
                
                // Action Section
                HStack {
                    if !isResearched {
                        BuildCosts(costs: type.cost)
                    }
                    
                    Spacer()
                    
                    if isResearched {
                        Label("Completed", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(SpaceTheme.success)
                    } else if let remaining = timeRemaining {
                        ConstructionProgressView(timeRemaining: remaining)
                    } else {
                        Button(action: onResearch) {
                            Text("Research")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .buttonStyle(SpaceButtonStyle())
                        .disabled(!isAvailable)
                    }
                }
            }
            .padding(12)
        }
    }
} 