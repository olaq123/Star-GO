import SwiftUI

struct ResourceDetailsView: View {
    let planet: Planet
    @Binding var selectedResource: ResourceType?
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(ResourceType.allCases, id: \.self) { resourceType in
                ResourceRow(
                    type: resourceType,
                    isSelected: selectedResource == resourceType,
                    planet: planet,
                    onTap: { selectedResource = resourceType }
                )
            }
        }
        .padding(.horizontal, 8)
    }
}

private struct ResourceRow: View {
    let type: ResourceType
    let isSelected: Bool
    let planet: Planet
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: type.iconName)
                    .font(.system(size: 14))
                    .foregroundColor(SpaceTheme.accent)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(type.displayName)
                        .font(.system(size: 12, weight: .medium))
                    
                    let production = planet.calculateResourceProduction()
                    
                    Group {
                        switch type {
                        case .metal:
                            Text("+\(Int(production.metal))/h")
                        case .crystal:
                            Text("+\(Int(production.crystal))/h")
                        case .energy:
                            Text("+\(Int(production.energy))/h")
                        }
                    }
                    .font(.system(size: 10))
                    .foregroundColor(SpaceTheme.success)
                }
                .foregroundColor(SpaceTheme.foreground)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(SpaceTheme.accent)
                }
            }
            .padding(8)
            .background(isSelected ? SpaceTheme.accent.opacity(0.1) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#if DEBUG
struct ResourceDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ResourceDetailsView(
            planet: Planet(name: "Test Planet"),
            selectedResource: .constant(.metal)
        )
        .preferredColorScheme(.dark)
    }
}
#endif 