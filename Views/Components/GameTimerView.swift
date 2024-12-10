import SwiftUI

struct GameTimerView: View {
    @StateObject private var timerState = TimerState()
    
    var body: some View {
        Text(timerState.formattedTime)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(SpaceTheme.foreground)
            .onAppear {
                timerState.startTimer()
            }
            .onDisappear {
                timerState.stopTimer()
            }
    }
}

class TimerState: ObservableObject {
    @Published var formattedTime: String = "00:00:00"
    private var timer: Timer?
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTime()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTime() {
        let currentTick = GameTime.shared.getCurrentTick()
        let hours = currentTick / 3600
        let minutes = (currentTick % 3600) / 60
        let seconds = currentTick % 60
        
        formattedTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    deinit {
        stopTimer()
    }
}

#if DEBUG
struct GameTimerView_Previews: PreviewProvider {
    static var previews: some View {
        GameTimerView()
            .preferredColorScheme(.dark)
            .padding()
            .background(Color.black)
    }
}
#endif 