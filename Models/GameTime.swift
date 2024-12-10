import Foundation

class GameTime {
    static let shared = GameTime()
    private var timer: Timer?
    private let tickDuration: TimeInterval = 1.0 // 1 second per tick
    
    @Published private(set) var currentTick: Int = 30 // Start at 30 seconds
    
    private init() {
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: tickDuration, repeats: true) { [weak self] _ in
            self?.updateTick()
        }
    }
    
    private func updateTick() {
        if currentTick > 0 {
            currentTick -= 1
        } else {
            // When reaching 0, reset to 30 seconds
            currentTick = 30
        }
    }
    
    func getCurrentTick() -> Int {
        return currentTick
    }
    
    deinit {
        timer?.invalidate()
    }
} 
