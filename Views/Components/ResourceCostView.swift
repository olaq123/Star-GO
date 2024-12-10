import SwiftUI

struct ResourceCostView: View {
    let icon: String
    let value: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(SpaceTheme.accent)
            
            Text("\(value)")
                .font(.system(size: 12))
                .foregroundColor(SpaceTheme.foreground.opacity(0.7))
        }
    }
}

#if DEBUG
struct ResourceCostView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            SpaceTheme.background
            HStack {
                ResourceCostView(icon: "cube.fill", value: 100)
                ResourceCostView(icon: "diamond.fill", value: 50)
                ResourceCostView(icon: "bolt.fill", value: 25)
            }
            .padding()
        }
        .preferredColorScheme(.dark)
    }
}
#endif 