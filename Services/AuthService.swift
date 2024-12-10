import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import UIKit
import CryptoKit

@MainActor
class AuthService: NSObject {
    static let shared = AuthService()
    private var currentNonce: String?
    
    private override init() {
        super.init()
        // Initialize Google Sign In
        if let clientId = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
        }
    }
    
    // Email Authentication
    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func signUp(email: String, password: String, username: String) async throws {
        // Create the user
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        
        // Save additional user data
        try await FirestoreService.shared.saveUser(result.user, username: username)
    }
    
    // Google Sign In
    func signInWithGoogle(presenting: UIViewController) async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw GameError.authenticationFailed
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)
        guard let idToken = result.user.idToken?.tokenString else {
            throw GameError.authenticationFailed
        }
        
        let accessToken = result.user.accessToken.tokenString
        let credential = OAuthProvider.credential(
            providerID: AuthProviderID.google,
            idToken: idToken,
            rawNonce: "",
            accessToken: accessToken
        )
        
        let authResult = try await Auth.auth().signIn(with: credential)
        try await FirestoreService.shared.saveUser(authResult.user, username: result.user.profile?.name ?? "")
    }
    
    // Apple Sign In
    func startSignInWithAppleFlow() async throws -> ASAuthorization {
        let nonce = generateNonce()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        return try await withCheckedThrowingContinuation { continuation in
            let delegate = AppleSignInDelegate(continuation: continuation)
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = delegate
            authorizationController.presentationContextProvider = delegate
            authorizationController.performRequests()
            
            // Store delegate to prevent deallocation
            objc_setAssociatedObject(self, "AppleSignInDelegate", delegate, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func handleAppleSignIn(_ authorization: ASAuthorization) async throws {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let idTokenString = String(data: appleIDCredential.identityToken!, encoding: .utf8) else {
            throw GameError.authenticationFailed
        }
        
        let credential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: idTokenString,
            rawNonce: nonce,
            accessToken: nil
        )
        
        let result = try await Auth.auth().signIn(with: credential)
        
        // Get the first available scene
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            return
        }
        
        let window = windowScene.windows.first { $0.isKeyWindow }
        window?.rootViewController?.dismiss(animated: true)
        
        // Save user data
        let fullName = [
            appleIDCredential.fullName?.givenName,
            appleIDCredential.fullName?.familyName
        ].compactMap { $0 }.joined(separator: " ")
        
        try await FirestoreService.shared.saveUser(result.user, username: fullName)
    }
    
    // Anonymous Sign In
    func signInAnonymously() async throws {
        try await Auth.auth().signInAnonymously()
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
    
    func isAuthenticated() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    // Link anonymous account with email
    func linkAnonymousUser(withEmail email: String, password: String) async throws {
        guard let user = Auth.auth().currentUser, user.isAnonymous else {
            throw GameError.notAuthenticated
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await user.link(with: credential)
    }
    
    // MARK: - Helper Functions
    private func generateNonce(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// Helper class for Apple Sign In
private class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    let continuation: CheckedContinuation<ASAuthorization, Error>
    
    init(continuation: CheckedContinuation<ASAuthorization, Error>) {
        self.continuation = continuation
        super.init()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            fatalError("No key window found")
        }
        return window
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        continuation.resume(returning: authorization)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation.resume(throwing: error)
    }
}