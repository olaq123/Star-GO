import SwiftUI

struct StarsBackgroundView: View {
    var body: some View {
        ZStack {
            // Deep space background
            Color(uiColor: .black).ignoresSafeArea()
            
            // Stars layer
            FixedStarsBackgroundView()
                .ignoresSafeArea()
        }
    }
}

#if DEBUG
struct StarsBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        StarsBackgroundView()
            .preferredColorScheme(.dark)
    }
}
#endif 