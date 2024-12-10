import SwiftUI

struct PlanetDashboardView: View {
    let planet: Planet?
    @StateObject private var updateTimer = TimerState()
    
    var body: some View {
        if let planet = planet {
            ScrollView {
                VStack(spacing: 24) {
                    // Buildings
                    BuildingsView(planet: planet)
                    
                    // Shipyard
                    ShipyardView(planet: planet)
                    
                    // Defenses
                    DefensesView(planet: planet)
                }
                .padding()
            }
            .onAppear {
                updateTimer.startTimer()
            }
            .onDisappear {
                updateTimer.stopTimer()
            }
        } else {
            Text("No Planet Selected")
                .foregroundColor(SpaceTheme.foreground)
        }
    }
}

#if DEBUG
struct PlanetDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        PlanetDashboardView(planet: Planet(name: "Test Planet"))
            .preferredColorScheme(.dark)
    }
}
#endif 