import Foundation

class Planet: Codable {
    let id: UUID
    var name: String
    var resources: Resources
    var buildings: [Building]
    var fleet: Fleet
    weak var owner: Player?
    var researchSystem: Research.System = Research.System()
    private(set) var constructionQueue: [(building: Building, completionTick: Int)] = []
    var location: Location?
    var isDiscovered: Bool = false
    var discoveryDate: Date?
    var defenses: [Defense] = []
    private(set) var defenseConstructionQueue: [(defense: Defense, completionTick: Int)] = []
    let creationDate: Date
    
    var isProtected: Bool {
        // Protection lasts for 30 days from creation
        guard let creationDate = discoveryDate else { return false }
        let protectionPeriod: TimeInterval = 30 * 24 * 60 * 60 // 30 days in seconds
        return Date().timeIntervalSince(creationDate) < protectionPeriod
    }
    
    var protectionTimeRemaining: TimeInterval? {
        guard let creationDate = discoveryDate, isProtected else { return nil }
        let protectionPeriod: TimeInterval = 30 * 24 * 60 * 60
        return protectionPeriod - Date().timeIntervalSince(creationDate)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, resources, buildings, fleet, location, 
             isDiscovered, discoveryDate, defenses, constructionQueue,
             defenseConstructionQueue, researchSystem, creationDate
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        resources = try container.decode(Resources.self, forKey: .resources)
        buildings = try container.decode([Building].self, forKey: .buildings)
        fleet = try container.decode(Fleet.self, forKey: .fleet)
        location = try container.decodeIfPresent(Location.self, forKey: .location)
        isDiscovered = try container.decode(Bool.self, forKey: .isDiscovered)
        discoveryDate = try container.decodeIfPresent(Date.self, forKey: .discoveryDate)
        defenses = try container.decode([Defense].self, forKey: .defenses)
        constructionQueue = []
        defenseConstructionQueue = []
        researchSystem = try container.decode(Research.System.self, forKey: .researchSystem)
        creationDate = try container.decode(Date.self, forKey: .creationDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(resources, forKey: .resources)
        try container.encode(buildings, forKey: .buildings)
        try container.encode(fleet, forKey: .fleet)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encode(isDiscovered, forKey: .isDiscovered)
        try container.encodeIfPresent(discoveryDate, forKey: .discoveryDate)
        try container.encode(defenses, forKey: .defenses)
        try container.encode(researchSystem, forKey: .researchSystem)
        try container.encode(creationDate, forKey: .creationDate)
    }
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.resources = Resources(metal: 500, crystal: 300, energy: 100)
        self.buildings = []
        self.fleet = Fleet()
        self.researchSystem = Research.System()
        self.defenses = []
        self.constructionQueue = []
        self.defenseConstructionQueue = []
        self.discoveryDate = nil
        self.isDiscovered = false
        self.creationDate = Date()
    }
    
    // Discovery
    func discover(at location: Location) {
        self.location = location
        self.isDiscovered = true
        self.discoveryDate = Date()
    }
    
    // Ship Building
    func canBuildShip(_ type: ShipType) -> Bool {
        // Check if we have a shipyard
        guard buildings.contains(where: { $0.type == .shipyard }) else {
            return false
        }
        
        // Check if we have enough resources
        return resources.canAfford(type.buildCost)
    }
    
    func buildShip(_ type: ShipType) throws {
        guard canBuildShip(type) else {
            throw GameError.invalidOperation
        }
        
        // Deduct resources
        try resources.subtract(type.buildCost)
        
        // Create new ship with 1 tick build time
        let ship = Ship(type: type)
        let completionTick = GameTime.shared.getCurrentTick() + 1
        fleet.addToConstructionQueue(ship: ship, completionTick: completionTick)
    }
    
    // Add methods to manage construction queues
    func addToConstructionQueue(building: Building, completionTick: Int) {
        constructionQueue.append((building, completionTick))
    }
    
    func addToDefenseQueue(defense: Defense, completionTick: Int) {
        defenseConstructionQueue.append((defense, completionTick))
    }
    
    var isConstructing: Bool {
        !constructionQueue.isEmpty
    }
    
    var isConstructingDefense: Bool {
        !defenseConstructionQueue.isEmpty
    }
    
    // Add this method to the Planet class
    func update(tick: Int) {
        // Update buildings
        buildings.forEach { $0.update(tick: tick) }
        
        // Update fleet
        fleet.update(tick: tick)
        
        // Update research
        researchSystem.update(tick: tick)
        
        // Process construction queue
        let (completedBuildings, remainingQueue) = constructionQueue.partition { $0.completionTick <= tick }
        
        completedBuildings.forEach { construction in
            buildings.append(construction.building)
        }
        
        constructionQueue = remainingQueue
        
        // Process defense construction queue
        let (completedDefenses, remainingDefenses) = defenseConstructionQueue.partition { $0.completionTick <= tick }
        
        completedDefenses.forEach { construction in
            defenses.append(construction.defense)
        }
        
        defenseConstructionQueue = remainingDefenses
    }
    
    // Add these methods to the Planet class
    func canBuildDefense(_ type: DefenseType) -> Bool {
        // Check if command center exists
        guard buildings.contains(where: { $0.type == .commandCenter }) else {
            return false
        }
        
        // Check defense limit
        let currentCount = getDefenseCount(type)
        guard currentCount < getDefenseLimit() else {
            return false
        }
        
        // Check resources
        return resources.canAfford(type.buildCost)
    }

    func buildDefense(_ type: DefenseType) throws {
        guard canBuildDefense(type) else {
            throw GameError.invalidOperation
        }
        
        // Deduct resources
        try resources.subtract(type.buildCost)
        
        // Create new defense
        let defense = Defense(type: type)
        let completionTick = GameTime.shared.getCurrentTick() + type.buildTicks
        
        // Add to construction queue
        addToDefenseQueue(defense: defense, completionTick: completionTick)
    }
    
    // Add this method to Planet class
    func calculateResourceProduction() -> Resources {
        var totalProduction = Resources(metal: 0, crystal: 0, energy: 0)
        
        for building in buildings {
            if let production = building.type.resourceProduction {
                let levelMultiplier = pow(1.1, Double(building.level - 1))
                totalProduction.metal += production.metal * levelMultiplier
                totalProduction.crystal += production.crystal * levelMultiplier
                totalProduction.energy += production.energy * levelMultiplier
            }
        }
        
        // Apply research bonuses
        let metalBonus = researchSystem.getProductionBonus(for: .metal)
        let crystalBonus = researchSystem.getProductionBonus(for: .crystal)
        let energyBonus = researchSystem.getProductionBonus(for: .energy)
        
        totalProduction.metal *= metalBonus
        totalProduction.crystal *= crystalBonus
        totalProduction.energy *= energyBonus
        
        return totalProduction
    }
    
    // Add these methods to the Planet class
    func getDefenseLimit() -> Int {
        // Get command center level
        let commandCenter = buildings.first { $0.type == .commandCenter }
        let level = commandCenter?.level ?? 0
        
        // Calculate defense limit based on command center level
        if level < 5 {
            return 2  // Basic limit
        } else if level < 10 {
            return 4  // Medium limit
        } else {
            return 6  // High level limit
        }
    }

    func getDefenseCount(_ type: DefenseType) -> Int {
        defenses.filter { $0.type == type }.count
    }

    // Add this method to calculate total defense power
    func calculateDefensePower() -> DefensePower {
        var power = DefensePower()
        
        for defense in defenses {
            // Apply research bonuses
            let shieldBonus = researchSystem.isResearched(.shieldTechnology) ? 
                Research.ResearchType.shieldTechnology.bonusEffect : 0
                
            power.shieldStrength += defense.type.shieldStrength * (1 + shieldBonus)
            power.weaponPower += defense.type.weaponPower
        }
        
        return power
    }
    
    // Add this method to the Planet class
    func canBuildNewBuilding(_ type: BuildingType) -> Bool {
        // Check if we have enough resources
        guard resources.canAfford(type.buildCost) else {
            return false
        }
        
        // Check if we're already constructing this type
        if constructionQueue.contains(where: { $0.building.type == type }) {
            return false
        }
        
        return true
    }

    func startConstruction(type: BuildingType, currentTick: Int) throws {
        guard canBuildNewBuilding(type) else {
            throw GameError.invalidOperation
        }
        
        // Deduct resources
        try resources.subtract(type.buildCost)
        
        // Create new building
        let building = Building(type: type)
        
        // Add to construction queue with 1 tick duration
        addToConstructionQueue(building: building, completionTick: currentTick + 1)
    }

    func canUpgradeBuilding(_ building: Building) -> Bool {
        // Check if building is already being upgraded
        guard !building.upgradeInProgress else {
            return false
        }
        
        // Check if we have enough resources
        let cost = building.type.upgradeCost(forLevel: building.level)
        return resources.canAfford(cost)
    }

    func upgradeBuilding(_ building: Building) throws {
        guard canUpgradeBuilding(building) else {
            throw GameError.invalidOperation
        }
        
        // Deduct resources
        let cost = building.type.upgradeCost(forLevel: building.level)
        try resources.subtract(cost)
        
        // Start upgrade with 1 tick duration
        building.upgradeInProgress = true
        building.upgradeCompletionTick = GameTime.shared.getCurrentTick() + 1
    }
    
    // ... rest of the implementation ...
}