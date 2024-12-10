import Foundation

struct SeededRandomGenerator {
    private var seed: UInt64
    
    init(seed: Int) {
        self.seed = UInt64(abs(seed))
    }
    
    mutating func nextDouble(in range: ClosedRange<Double>) -> Double {
        seed = seed &* 6364136223846793005 &+ 1442695040888963407
        
        let ratio = Double(seed) / Double(UInt64.max)
        
        return range.lowerBound + (range.upperBound - range.lowerBound) * ratio
    }
} 