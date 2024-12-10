import Foundation

class FleetMission: Codable {
    enum MissionType: String, Codable {
        case attack
        case defend
        case scout
        case transport
    }
    
    let type: MissionType
    let source: Planet
    let target: Planet
    let startTick: Int
    let duration: Int
    
    var isComplete: Bool {
        GameTime.shared.getCurrentTick() >= startTick + duration
    }
    
    init(type: MissionType, source: Planet, target: Planet, startTick: Int, duration: Int) {
        self.type = type
        self.source = source
        self.target = target
        self.startTick = startTick
        self.duration = duration
    }
    
    func update(tick: Int) {
        guard isComplete else { return }
        
        switch type {
        case .attack:
            performAttack()
        case .scout:
            performScouting()
        case .defend:
            performDefense()
        case .transport:
            performTransport()
        }
    }
    
    private func performAttack() {
        let attackingFleet = source.fleet
        let defendingFleet = target.fleet
        let damage = attackingFleet.totalAttackPower
        if let randomShip = defendingFleet.ships.randomElement() {
            randomShip.takeDamage(damage)
        }
    }
    
    private func performScouting() {
        // Implementation for scouting missions
    }
    
    private func performDefense() {
        // Implementation for defense missions
    }
    
    private func performTransport() {
        // Implementation for resource transport missions
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case type, source, target, startTick, duration
    }
} 