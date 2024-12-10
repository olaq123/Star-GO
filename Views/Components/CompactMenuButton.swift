import SwiftUI

struct CompactMenuButton: View {
    let icon: String
    let selectedIcon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? selectedIcon : icon)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? SpaceTheme.accent : SpaceTheme.foreground)
                
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? SpaceTheme.accent : SpaceTheme.foreground)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? SpaceTheme.accent.opacity(0.1) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
} 