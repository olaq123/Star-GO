import Foundation

extension Research {
    class System: Codable {
        private var completedResearch: Set<Research.ResearchType> = []
        private var currentResearch: ResearchQueueItem?
        
        struct ResearchQueueItem: Codable {
            let type: Research.ResearchType
            let completionTick: Int
        }
        
        private enum CodingKeys: String, CodingKey {
            case completedResearch, currentResearch
        }
        
        init() {}
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            completedResearch = try container.decode(Set<Research.ResearchType>.self, forKey: .completedResearch)
            currentResearch = try container.decodeIfPresent(ResearchQueueItem.self, forKey: .currentResearch)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(completedResearch, forKey: .completedResearch)
            try container.encodeIfPresent(currentResearch, forKey: .currentResearch)
        }
        
        func isResearched(_ type: Research.ResearchType) -> Bool {
            completedResearch.contains(type)
        }
        
        func isResearching(_ type: Research.ResearchType) -> Bool {
            currentResearch?.type == type
        }
        
        func canResearch(_ type: Research.ResearchType) -> Bool {
            guard !isResearched(type) && !isResearching(type) else {
                return false
            }
            return type.prerequisites.allSatisfy { isResearched($0) }
        }
        
        func startResearch(_ type: Research.ResearchType, currentTick: Int) {
            guard canResearch(type) else { return }
            currentResearch = ResearchQueueItem(
                type: type,
                completionTick: currentTick + type.researchTime
            )
        }
        
        func update(tick: Int) {
            guard let research = currentResearch else { return }
            if tick >= research.completionTick {
                completedResearch.insert(research.type)
                currentResearch = nil
            }
        }
        
        func getResearchTimeRemaining(_ type: Research.ResearchType) -> Int? {
            guard let research = currentResearch,
                  research.type == type else { return nil }
            return research.completionTick - GameTime.shared.getCurrentTick()
        }
        
        func getProductionBonus(for resourceType: ResourceType) -> Double {
            var bonus = 1.0
            
            if isResearched(.improvedMining) {
                switch resourceType {
                case .metal, .crystal:
                    bonus += Research.ResearchType.improvedMining.bonusEffect
                default:
                    break
                }
            }
            
            if isResearched(.advancedPowerSystems) && resourceType == .energy {
                bonus += Research.ResearchType.advancedPowerSystems.bonusEffect
            }
            
            return bonus
        }
    }
} 