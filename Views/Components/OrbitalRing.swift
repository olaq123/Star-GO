import SwiftUI

struct OrbitalRing: View {
    let radius: CGFloat
    let dotCount: Int
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            ForEach(0..<dotCount, id: \.self) { index in
                let angle = (2 * Double.pi * Double(index)) / Double(dotCount)
                let x = radius * CGFloat(cos(angle))
                let y = radius * CGFloat(sin(angle))
                
                // Only draw the dot if we have valid coordinates
                if x.isFinite && y.isFinite {
                    Circle()
                        .fill(SpaceTheme.accent)
                        .frame(width: 6, height: 6)
                        .offset(x: x, y: y)
                }
            }
        }
        .rotationEffect(.degrees(rotation))
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

#if DEBUG
struct OrbitalRing_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            OrbitalRing(radius: 100, dotCount: 8)
        }
    }
}
#endif 