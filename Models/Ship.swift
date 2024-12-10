import Foundation

class Ship: Codable {
    let id: UUID
    let type: ShipType
    var health: Double
    
    init(type: ShipType) {
        self.id = UUID()
        self.type = type
        self.health = type.shieldStrength
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, type, health
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(ShipType.self, forKey: .type)
        health = try container.decode(Double.self, forKey: .health)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(health, forKey: .health)
    }
    
    func takeDamage(_ amount: Double) {
        health = max(0, health - amount)
    }
    
    var isDestroyed: Bool {
        health <= 0
    }
} 