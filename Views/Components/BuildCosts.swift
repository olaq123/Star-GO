import SwiftUI

struct BuildCosts: View {
    let costs: Resources
    
    var body: some View {
        HStack(spacing: 12) {
            ResourceCostView(icon: "cube.fill", value: Int(costs.metal))
            ResourceCostView(icon: "diamond.fill", value: Int(costs.crystal))
            ResourceCostView(icon: "bolt.fill", value: Int(costs.energy))
        }
    }
} 