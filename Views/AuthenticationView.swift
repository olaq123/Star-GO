import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var isSignUp = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            StarsBackgroundView()
            
            VStack(spacing: 30) {
                // Logo
                logoSection
                
                // Auth Form
                VStack(spacing: 20) {
                    // Title
                    Text(isSignUp ? "Create Account" : "Welcome Back")
                        .font(.title2)
                        .foregroundColor(SpaceTheme.foreground)
                    
                    // Form Fields
                    authFormSection
                    
                    // Action Buttons
                    actionButtonsSection
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(SpaceTheme.accent.opacity(0.3))
                        Text("or")
                            .font(.caption)
                            .foregroundColor(SpaceTheme.foreground.opacity(0.7))
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(SpaceTheme.accent.opacity(0.3))
                    }
                    .padding(.horizontal)
                    
                    // Social Sign In Options
                    socialSignInSection
                    
                    // Toggle Sign In/Up
                    toggleAuthModeSection
                }
                .padding()
                .background(SpaceTheme.background.opacity(0.9))
                .cornerRadius(12)
                .padding(.horizontal, 24)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - View Components
    
    private var logoSection: some View {
        VStack {
            Image(systemName: "star.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(SpaceTheme.accent)
            
            Text("Star GO")
                .font(.largeTitle)
                .foregroundColor(SpaceTheme.foreground)
        }
    }
    
    private var authFormSection: some View {
        VStack(spacing: 16) {
            if isSignUp {
                TextField("Username", text: $username)
                    .textFieldStyle(SpaceTextFieldStyle())
            }
            
            TextField("Email", text: $email)
                .textFieldStyle(SpaceTextFieldStyle())
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(SpaceTextFieldStyle())
                .textContentType(isSignUp ? .newPassword : .password)
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Button(action: handleMainAction) {
                if authViewModel.isLoading {
                    ProgressView()
                        .tint(SpaceTheme.foreground)
                } else {
                    Text(isSignUp ? "Sign Up" : "Sign In")
                        .font(.headline)
                }
            }
            .buttonStyle(SpaceButtonStyle())
            .disabled(authViewModel.isLoading)
            
            Button {
                Task {
                    do {
                        try await authViewModel.signInAnonymously()
                    } catch {
                        showError = true
                        errorMessage = error.localizedDescription
                    }
                }
            } label: {
                Text("Continue as Guest")
                    .font(.subheadline)
                    .foregroundColor(SpaceTheme.accent)
            }
            .disabled(authViewModel.isLoading)
        }
    }
    
    private var socialSignInSection: some View {
        VStack(spacing: 12) {
            // Apple Sign In
            SignInWithAppleButton { request in
                request.requestedScopes = [.email, .fullName]
            } onCompletion: { result in
                Task {
                    switch result {
                    case .success(let authorization):
                        do {
                            try await authViewModel.signInWithApple(authorization: authorization)
                        } catch {
                            print("Error signing in with Apple: \(error)")
                        }
                    case .failure(let error):
                        print("Apple sign in failed: \(error)")
                    }
                }
            }
            .frame(maxWidth: 280, minHeight: 44)
            .cornerRadius(8)
            
            // Google Sign In Button with Material Design
            Button(action: {
                Task {
                    do {
                        try await authViewModel.signInWithGoogle()
                    } catch {
                        print("Error signing in with Google: \(error)")
                    }
                }
            }) {
                HStack {
                    // Content wrapper (matches gsi-material-button-content-wrapper)
                    HStack(spacing: 12) {
                        // Google Logo (matches gsi-material-button-icon)
                        Image("google_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        
                        // Button Text (matches gsi-material-button-contents)
                        Text("Sign in with Google")
                            .font(.custom("Roboto", size: 14))
                            .fontWeight(.medium)
                            .foregroundColor(Color(hex: "1f1f1f"))
                            .lineLimit(1)
                            .layoutPriority(1.0)
                        
                        Spacer(minLength: 0)
                    }
                }
                .frame(maxWidth: 400, minHeight: 40)
                .padding(.horizontal, 12)
                .background(
                    ZStack {
                        // Normal background
                        Color.white
                        
                        // Hover/Press state overlay (matches gsi-material-button-state)
                        Color.black.opacity(0.0)
                            .animation(.easeInOut(duration: 0.218), value: true)
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(hex: "747775"), lineWidth: 1)
                )
                .cornerRadius(4)
                // Hover effect
                .shadow(color: Color.black.opacity(0), radius: 0, x: 0, y: 0)
                .hoverEffect()
                // Disabled state
                .opacity(authViewModel.isLoading ? 0.38 : 1)
                // Transition animations
                .animation(.easeInOut(duration: 0.218), value: authViewModel.isLoading)
            }
            .buttonStyle(GoogleButtonStyle())
            .disabled(authViewModel.isLoading)
        }
        .padding(.horizontal)
    }
    
    private var toggleAuthModeSection: some View {
        Button {
            withAnimation {
                isSignUp.toggle()
                email = ""
                password = ""
                username = ""
            }
        } label: {
            Text(isSignUp ? "Already have an account? Sign In" : "New to Star GO? Sign Up")
                .font(.subheadline)
                .foregroundColor(SpaceTheme.accent)
        }
    }
    
    // MARK: - Actions
    
    private func handleMainAction() {
        Task {
            do {
                if isSignUp {
                    try await authViewModel.signUp(email: email, password: password, username: username)
                } else {
                    try await authViewModel.signIn(email: email, password: password)
                }
            } catch {
                showError = true
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Custom Text Field Style
struct SpaceTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(SpaceTheme.background)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(SpaceTheme.accent.opacity(0.3), lineWidth: 1)
            )
            .foregroundColor(SpaceTheme.foreground)
    }
}

// MARK: - Custom Button Style
struct GoogleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed ? 
                Color.black.opacity(0.12) :
                configuration.isPressed ? 
                Color.black.opacity(0.08) : 
                Color.clear
            )
            .shadow(
                color: configuration.isPressed ? Color.clear :
                       Color(hex: "3c4043").opacity(0.30),
                radius: 1,
                x: 0,
                y: 1
            )
            .shadow(
                color: configuration.isPressed ? Color.clear :
                       Color(hex: "3c4043").opacity(0.15),
                radius: 2,
                x: 0,
                y: 1
            )
            .animation(.easeInOut(duration: 0.218), value: configuration.isPressed)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}