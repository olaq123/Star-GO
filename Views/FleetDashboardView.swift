import SwiftUI

struct FleetDashboardView: View {
    @StateObject private var viewModel = FleetDashboardViewModel()
    
    var body: some View {
        if viewModel.totalShips == 0 {
            EmptyFleetView()
        } else {
            ScrollView {
                VStack(spacing: 16) {
                    // Overview Card
                    SpaceCardView {
                        VStack(spacing: 16) {
                            Text("Fleet Overview")
                                .font(.headline)
                                .foregroundColor(SpaceTheme.foreground)
                            
                            // Statistics
                            VStack(spacing: 8) {
                                StatisticRow(
                                    title: "Total Ships",
                                    value: "\(viewModel.totalShips)"
                                )
                                
                                StatisticRow(
                                    title: "Total Attack Power",
                                    value: "\(Int(viewModel.totalAttackPower))"
                                )
                                
                                StatisticRow(
                                    title: "Total Shield Strength",
                                    value: "\(Int(viewModel.totalShieldStrength))"
                                )
                            }
                            
                            Divider()
                                .background(SpaceTheme.accent.opacity(0.3))
                            
                            // Ship Types
                            VStack(spacing: 8) {
                                ForEach(ShipType.allCases, id: \.self) { type in
                                    FleetShipTypeRow(
                                        type: type,
                                        count: viewModel.shipCount(for: type)
                                    )
                                }
                            }
                        }
                        .padding()
                    }
                }
                .padding()
            }
        }
    }
}

struct StatisticRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(SpaceTheme.foreground.opacity(0.7))
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(SpaceTheme.foreground)
        }
    }
}

struct FleetShipTypeRow: View {
    let type: ShipType
    let count: Int
    
    var body: some View {
        HStack {
            Image(systemName: type.iconName)
                .font(.system(size: 14))
                .foregroundColor(SpaceTheme.accent)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(type.displayName)
                    .font(.system(size: 14))
                    .foregroundColor(SpaceTheme.foreground)
                
                Text("\(count) available")
                    .font(.system(size: 10))
                    .foregroundColor(SpaceTheme.foreground.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct EmptyFleetView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "airplane.circle")
                .font(.system(size: 48))
                .foregroundColor(SpaceTheme.accent.opacity(0.5))
            
            Text("No Fleets Available")
                .font(.system(size: 16))
                .foregroundColor(SpaceTheme.foreground.opacity(0.7))
            
            Text("Build ships in the shipyard to create a fleet")
                .font(.system(size: 14))
                .foregroundColor(SpaceTheme.foreground.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@MainActor
class FleetDashboardViewModel: ObservableObject {
    @Published var fleets: [Fleet] = []
    
    var totalShips: Int {
        fleets.reduce(0) { $0 + $1.ships.count }
    }
    
    var totalAttackPower: Double {
        fleets.reduce(0) { $0 + $1.totalAttackPower }
    }
    
    var totalShieldStrength: Double {
        fleets.reduce(0) { total, fleet in
            total + fleet.ships.reduce(0) { $0 + $1.type.shieldStrength }
        }
    }
    
    func shipCount(for type: ShipType) -> Int {
        fleets.reduce(0) { count, fleet in
            count + fleet.ships.filter { $0.type == type }.count
        }
    }
    
    init() {
        if let player = GameManager.shared.gameState.currentPlayer {
            fleets = [player.homePlanet.fleet]
        }
    }
}

#if DEBUG
struct FleetDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        FleetDashboardView()
            .preferredColorScheme(.dark)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
#endif

struct FleetCard: View {
    let fleet: Fleet
    
    var body: some View {
        SpaceCardView {
            VStack(alignment: .leading, spacing: 8) {
                // Fleet Header
                HStack {
                    Image(systemName: "airplane.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(SpaceTheme.accent)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Fleet \(fleet.id.uuidString.prefix(8))")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(SpaceTheme.foreground)
                        
                        Text("\(fleet.ships.count) ships")
                            .font(.system(size: 12))
                            .foregroundColor(SpaceTheme.foreground.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    if let mission = fleet.mission {
                        MissionStatusBadge(type: mission.type)
                    }
                }
                
                // Ship List
                if !fleet.ships.isEmpty {
                    Divider()
                        .background(SpaceTheme.accent.opacity(0.3))
                    
                    ForEach(fleet.ships, id: \.id) { ship in
                        FleetShipRow(ship: ship)
                    }
                }
            }
            .padding(12)
        }
    }
}

struct FleetShipRow: View {
    let ship: Ship
    
    var body: some View {
        HStack {
            Image(systemName: "airplane")
                .font(.system(size: 14))
                .foregroundColor(SpaceTheme.accent)
            
            Text(ship.type.rawValue.capitalized)
                .font(.system(size: 14))
                .foregroundColor(SpaceTheme.foreground)
            
            Spacer()
            
            // Health Bar
            ProgressView(value: ship.health / ship.type.shieldStrength)
                .tint(healthColor)
                .frame(width: 60)
        }
    }
    
    private var healthColor: Color {
        let ratio = ship.health / ship.type.shieldStrength
        if ratio > 0.7 { return .green }
        if ratio > 0.3 { return .yellow }
        return .red
    }
}

struct MissionStatusBadge: View {
    let type: FleetMission.MissionType
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: missionIcon)
            Text(type.rawValue.capitalized)
        }
        .font(.system(size: 12))
        .foregroundColor(SpaceTheme.accent)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(SpaceTheme.accent.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var missionIcon: String {
        switch type {
        case .attack: return "burst.fill"
        case .defend: return "shield.fill"
        case .scout: return "binoculars.fill"
        case .transport: return "shippingbox.fill"
        }
    }
} 