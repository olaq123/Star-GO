import SwiftUI
import FirebaseAuth
import AuthenticationServices

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    private let authService = AuthService.shared
    private var stateListener: AuthStateDidChangeListenerHandle?
    
    init() {
        // Check initial auth state
        isAuthenticated = authService.isAuthenticated()
        
        // Listen for auth state changes
        stateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    deinit {
        if let handle = stateListener {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - Email Authentication
    
    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await authService.signIn(email: email, password: password)
    }
    
    func signUp(email: String, password: String, username: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await authService.signUp(email: email, password: password, username: username)
    }
    
    // MARK: - Social Authentication
    
    func signInWithGoogle() async throws {
        isLoading = true
        defer { isLoading = false }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            throw GameError.noRootViewController
        }
        
        try await authService.signInWithGoogle(presenting: rootViewController)
    }
    
    func signInWithApple(authorization: ASAuthorization) async throws {
        isLoading = true
        defer { isLoading = false }
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = appleIDCredential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            throw GameError.invalidCredentials
        }
        
        let nonce = UUID().uuidString
        
        let credential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: tokenString,
            rawNonce: nonce,
            accessToken: nil
        )
        
        try await Auth.auth().signIn(with: credential)
        
        // Save additional user data if this is a new user
        if let fullName = appleIDCredential.fullName {
            let displayName = [
                fullName.givenName,
                fullName.familyName
            ].compactMap { $0 }.joined(separator: " ")
            
            if !displayName.isEmpty {
                try await FirestoreService.shared.saveUser(
                    Auth.auth().currentUser!,
                    username: displayName
                )
            }
        }
    }
    
    func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) async throws {
        isLoading = true
        defer { isLoading = false }
        
        switch result {
        case .success(let authorization):
            try await signInWithApple(authorization: authorization)
            
        case .failure(let error):
            if (error as NSError).code == ASAuthorizationError.canceled.rawValue {
                throw GameError.userCancelled
            }
            throw error
        }
    }
    
    // MARK: - Anonymous Authentication
    
    func signInAnonymously() async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await authService.signInAnonymously()
    }
    
    func linkAnonymousAccount(withEmail email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await authService.linkAnonymousUser(withEmail: email, password: password)
    }
    
    // MARK: - Sign Out
    
    func signOut() throws {
        try authService.signOut()
    }
    
    // MARK: - Helpers
    
    var currentUser: User? {
        authService.getCurrentUser()
    }
} 