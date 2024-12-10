import Foundation

class Fleet: Codable {
    let id: UUID
    var ships: [Ship]
    private var constructionQueue: [(ship: Ship, completionTick: Int)]
    var mission: FleetMission?
    
    // Codable support
    private enum CodingKeys: String, CodingKey {
        case id, ships, constructionQueue, mission
    }
    
    private struct QueueItem: Codable {
        let ship: Ship
        let completionTick: Int
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        ships = try container.decode([Ship].self, forKey: .ships)
        let queueItems = try container.decode([QueueItem].self, forKey: .constructionQueue)
        constructionQueue = queueItems.map { ($0.ship, $0.completionTick) }
        mission = try container.decodeIfPresent(FleetMission.self, forKey: .mission)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(ships, forKey: .ships)
        let queueItems = constructionQueue.map { QueueItem(ship: $0.ship, completionTick: $0.completionTick) }
        try container.encode(queueItems, forKey: .constructionQueue)
        try container.encodeIfPresent(mission, forKey: .mission)
    }
    
    init() {
        self.id = UUID()
        self.ships = []
        self.constructionQueue = []
        self.mission = nil
    }
    
    func add(ship: Ship) {
        ships.append(ship)
    }
    
    func update(tick: Int) {
        // Process construction queue
        let (completed, remaining) = constructionQueue.partition { $0.completionTick <= tick }
        
        completed.forEach { construction in
            ships.append(construction.ship)
        }
        
        constructionQueue = remaining
    }
    
    var totalAttackPower: Double {
        ships.reduce(0) { $0 + $1.type.attackPower }
    }
    
    // Add methods to access construction queue
    func addToConstructionQueue(ship: Ship, completionTick: Int) {
        constructionQueue.append((ship, completionTick))
    }
    
    var isConstructing: Bool {
        return !constructionQueue.isEmpty
    }
    
    func getConstructionStatus(for type: ShipType) -> Int? {
        if let construction = constructionQueue.first(where: { $0.ship.type == type }) {
            return construction.completionTick
        }
        return nil
    }
    
    func getConstructionTimeRemaining(_ type: ShipType) -> Int? {
        if let construction = constructionQueue.first(where: { $0.ship.type == type }) {
            return construction.completionTick - GameTime.shared.getCurrentTick()
        }
        return nil
    }
}

extension Array {
    func partition(by predicate: (Element) -> Bool) -> ([Element], [Element]) {
        var matching: [Element] = []
        var nonMatching: [Element] = []
        
        forEach { element in
            if predicate(element) {
                matching.append(element)
            } else {
                nonMatching.append(element)
            }
        }
        
        return (matching, nonMatching)
    }
} 