import SwiftUI

struct StatBadge: View {
    let icon: String
    let value: Int
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text("\(value)")
                .font(.system(size: 12, weight: .medium))
            Text(label)
                .font(.system(size: 10))
        }
        .foregroundColor(SpaceTheme.foreground.opacity(0.7))
    }
} 