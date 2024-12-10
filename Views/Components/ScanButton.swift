import SwiftUI

struct ScanButton: View {
    @StateObject private var locationManager = LocationManager.shared
    @State private var isScanning = false
    @State private var showCooldownAlert = false
    
    var body: some View {
        Button {
            scan()
        } label: {
            HStack {
                Image(systemName: isScanning ? "antenna.radiowaves.left.and.right" : "radar")
                Text(isScanning ? "Scanning..." : "Scan Area")
            }
            .padding()
            .background(SpaceTheme.accent)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .disabled(isScanning)
        .alert("Scan Cooldown", isPresented: $showCooldownAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Scanner is recharging. Please wait before scanning again.")
        }
    }
    
    private func scan() {
        isScanning = true
        
        Task {
            await locationManager.scanForPlanets()
            isScanning = false
        }
    }
}

#if DEBUG
struct ScanButton_Previews: PreviewProvider {
    static var previews: some View {
        ScanButton()
            .environmentObject(GameManager.shared)
    }
}
#endif 