import SwiftUI

struct PlanetView: View {
    let planet: Planet
    
    var body: some View {
        VStack(spacing: 16) {
            // Planet Header
            Text(planet.name)
                .font(.title)
                .foregroundColor(SpaceTheme.foreground)
            
            // Resources with production rate
            let production = planet.calculateResourceProduction()
            ResourceBarView(
                resources: planet.resources,
                production: Resources(
                    metal: production.metal / 3600,    // Convert hourly to per tick
                    crystal: production.crystal / 3600,
                    energy: production.energy / 3600
                )
            )
            
            // Rest of the planet view implementation...
        }
        .padding()
    }
}

#if DEBUG
struct PlanetView_Previews: PreviewProvider {
    static var previews: some View {
        PlanetView(planet: Planet(name: "Test Planet"))
            .preferredColorScheme(.dark)
    }
}
#endif 