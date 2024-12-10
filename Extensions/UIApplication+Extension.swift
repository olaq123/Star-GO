import UIKit

extension UIApplication {
    func rootViewController() async -> UIViewController? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = windowScene.windows.first,
                      let rootViewController = window.rootViewController else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: rootViewController)
            }
        }
    }
}
