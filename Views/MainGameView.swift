import SwiftUI

struct MainGameView: View {
    @EnvironmentObject private var gameManager: GameManager
    @State private var selectedTab = 0
    @State private var selectedResource: ResourceType?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                StarsBackgroundView()
                    .ignoresSafeArea()
                
                HStack(spacing: 0) {
                    // Left Side Menu
                    sideMenu(geometry: geometry)
                    
                    // Main Content Area
                    mainContent(geometry: geometry)
                }
            }
        }
        .ignoresSafeArea()
        .statusBar(hidden: true)
    }
    
    // MARK: - View Components
    
    private func sideMenu(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // Compact Header
            compactHeader
            
            Divider()
                .background(SpaceTheme.accent.opacity(0.3))
            
            // Navigation Menu
            navigationMenu
            
            Divider()
                .background(SpaceTheme.accent.opacity(0.3))
                .padding(.vertical, 4)
            
            // Resource Production Details
            if let planet = gameManager.gameState.currentPlayer?.homePlanet {
                VStack(spacing: 4) {
                    // Current Resources with production rate
                    let production = planet.calculateResourceProduction()
                    ResourceBarView(
                        resources: planet.resources,
                        production: Resources(
                            metal: production.metal / 3600,    // Convert hourly to per tick
                            crystal: production.crystal / 3600,
                            energy: production.energy / 3600
                        )
                    )
                    .padding(.horizontal, 4)
                }
                .id(planet.resources) // Force refresh when resources change
            }
            
            Spacer()
            
            // Settings Button
            settingsButton
        }
        .frame(width: geometry.size.width * 0.15)
        .background(
            SpaceTheme.background.opacity(0.9)
                .overlay(
                    Rectangle()
                        .fill(SpaceTheme.accent.opacity(0.1))
                        .frame(width: 1),
                    alignment: .trailing
                )
        )
    }
    
    private func mainContent(geometry: GeometryProxy) -> some View {
        ZStack {
            Group {
                switch selectedTab {
                case 0:
                    PlanetDashboardView(planet: gameManager.gameState.currentPlayer?.homePlanet)
                case 1:
                    StarMapView()
                case 2:
                    FleetDashboardView()
                case 3:
                    if let planet = gameManager.gameState.currentPlayer?.homePlanet {
                        ResearchDashboardView(planet: planet)
                    }
                default:
                    EmptyView()
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .frame(width: geometry.size.width * 0.85)
    }
    
    private var compactHeader: some View {
        VStack(spacing: 2) {
            Text("Star GO")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(SpaceTheme.accent)
            
            GameTimerView()
                .padding(.horizontal, 4)
        }
        .padding(.vertical, 4)
    }
    
    private var navigationMenu: some View {
        VStack(spacing: 1) {
            ForEach(0..<menuItems.count, id: \.self) { index in
                CompactMenuButton(
                    icon: menuItems[index].icon,
                    selectedIcon: menuItems[index].selectedIcon,
                    title: menuItems[index].title,
                    isSelected: selectedTab == index,
                    action: { withAnimation { selectedTab = index } }
                )
            }
        }
        .padding(.vertical, 2)
    }
    
    private var settingsButton: some View {
        CompactMenuButton(
            icon: "gear",
            selectedIcon: "gear.circle.fill",
            title: "Settings",
            isSelected: false,
            action: { /* Open Settings */ }
        )
        .padding(.vertical, 4)
    }
    
    // MARK: - Constants
    
    private let menuItems = [
        (title: "Planet", icon: "globe", selectedIcon: "globe.americas.fill"),
        (title: "Map", icon: "map", selectedIcon: "map.fill"),
        (title: "Fleet", icon: "airplane", selectedIcon: "airplane.circle.fill"),
        (title: "Research", icon: "atom", selectedIcon: "atom.circle.fill")
    ]
}

#if DEBUG
struct MainGameView_Previews: PreviewProvider {
    static var previews: some View {
        MainGameView()
            .environmentObject(GameManager())
            .preferredColorScheme(.dark)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
#endif 