import Foundation

struct Resources: Codable, Hashable {
    var metal: Double
    var crystal: Double
    var energy: Double
    
    init(metal: Double = 0, crystal: Double = 0, energy: Double = 0) {
        self.metal = metal
        self.crystal = crystal
        self.energy = energy
    }
    
    func canAfford(_ cost: Resources) -> Bool {
        return metal >= cost.metal &&
               crystal >= cost.crystal &&
               energy >= cost.energy
    }
    
    mutating func subtract(_ cost: Resources) throws {
        guard canAfford(cost) else {
            throw GameError.insufficientResources
        }
        
        metal -= cost.metal
        crystal -= cost.crystal
        energy -= cost.energy
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(metal)
        hasher.combine(crystal)
        hasher.combine(energy)
    }
    
    static func == (lhs: Resources, rhs: Resources) -> Bool {
        return lhs.metal == rhs.metal &&
               lhs.crystal == rhs.crystal &&
               lhs.energy == rhs.energy
    }
    
    enum CodingKeys: String, CodingKey {
        case metal, crystal, energy
    }
} 