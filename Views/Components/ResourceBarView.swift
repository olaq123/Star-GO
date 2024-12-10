import SwiftUI

struct ResourceBarView: View {
    let resources: Resources
    let production: Resources
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ResourceItem(
                icon: "cube.fill",
                value: Int(resources.metal),
                production: Int(production.metal),
                label: "Metal"
            )
            
            ResourceItem(
                icon: "diamond.fill",
                value: Int(resources.crystal),
                production: Int(production.crystal),
                label: "Crystal"
            )
            
            ResourceItem(
                icon: "bolt.fill",
                value: Int(resources.energy),
                production: Int(production.energy),
                label: "Energy"
            )
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(SpaceTheme.background.opacity(0.8))
        .cornerRadius(8)
    }
}

private struct ResourceItem: View {
    let icon: String
    let value: Int
    let production: Int
    let label: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(SpaceTheme.accent)
                .frame(width: 16)
            
            Text("\(value)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(SpaceTheme.foreground)
                .frame(minWidth: 50, alignment: .trailing)
            
            Text("+\(production)/tick")
                .font(.system(size: 10))
                .foregroundColor(SpaceTheme.success)
                .frame(minWidth: 40, alignment: .leading)
        }
    }
}

#if DEBUG
struct ResourceBarView_Previews: PreviewProvider {
    static var previews: some View {
        ResourceBarView(
            resources: Resources(metal: 1000, crystal: 500, energy: 200),
            production: Resources(metal: 10, crystal: 5, energy: 2)
        )
        .preferredColorScheme(.dark)
        .padding()
        .background(Color.black)
    }
}
#endif 