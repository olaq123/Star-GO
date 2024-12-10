import SwiftUI

struct FixedStarsBackgroundView: View {
    // Pre-calculated star positions
    private static let stars: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: CGFloat)] = {
        var result: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: CGFloat)] = []
        let starCount = 100
        var seed: UInt64 = 12345
        
        for _ in 0..<starCount {
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            let x = CGFloat(seed % 1000) / 1000.0
            
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            let y = CGFloat(seed % 1000) / 1000.0
            
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            let size = CGFloat(seed % 3) / 2.0 + 1.0
            
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            let opacity = CGFloat(seed % 700) / 1000.0 + 0.1
            
            result.append((x: x, y: y, size: size, opacity: opacity))
        }
        return result
    }()
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                for star in Self.stars {
                    let x = star.x * size.width
                    let y = star.y * size.height
                    
                    context.opacity = star.opacity
                    context.fill(
                        Path(ellipseIn: CGRect(
                            x: x,
                            y: y,
                            width: star.size,
                            height: star.size
                        )),
                        with: .color(.white)
                    )
                }
            }
        }
    }
}

#if DEBUG
struct FixedStarsBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            FixedStarsBackgroundView()
        }
        .preferredColorScheme(.dark)
    }
}
#endif 