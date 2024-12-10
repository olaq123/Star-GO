import Foundation

class Building: Codable {
    let id: UUID
    let type: BuildingType
    var level: Int
    var upgradeInProgress: Bool
    var upgradeCompletionTick: Int?
    
    init(type: BuildingType) {
        self.id = UUID()
        self.type = type
        self.level = 1
        self.upgradeInProgress = false
        self.upgradeCompletionTick = nil
    }
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case id, type, level, upgradeInProgress, upgradeCompletionTick
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(BuildingType.self, forKey: .type)
        level = try container.decode(Int.self, forKey: .level)
        upgradeInProgress = try container.decode(Bool.self, forKey: .upgradeInProgress)
        upgradeCompletionTick = try container.decodeIfPresent(Int.self, forKey: .upgradeCompletionTick)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(level, forKey: .level)
        try container.encode(upgradeInProgress, forKey: .upgradeInProgress)
        try container.encodeIfPresent(upgradeCompletionTick, forKey: .upgradeCompletionTick)
    }
    
    // MARK: - Building Logic
    var resourceProduction: Resources {
        guard let production = type.resourceProduction else {
            return Resources()
        }
        
        let levelMultiplier = pow(1.1, Double(level - 1))
        return Resources(
            metal: production.metal * levelMultiplier,
            crystal: production.crystal * levelMultiplier,
            energy: production.energy * levelMultiplier
        )
    }
    
    func update(tick: Int) {
        if let completionTick = upgradeCompletionTick,
           tick >= completionTick && upgradeInProgress {
            level += 1
            upgradeInProgress = false
            upgradeCompletionTick = nil
        }
    }
} 