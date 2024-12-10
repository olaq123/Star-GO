struct DefensePower: Codable {
    var shieldStrength: Double = 0
    var weaponPower: Double = 0
    
    // For future PVP implementation
    func calculateDamageReduction(against attackPower: Double) -> Double {
        // Shield reduces incoming damage
        let damageReduction = shieldStrength / (shieldStrength + attackPower)
        return max(0.1, min(0.9, damageReduction)) // Ensures between 10% and 90% reduction
    }
    
    // For future PVP implementation
    func calculateCounterAttackDamage() -> Double {
        return weaponPower
    }
} 