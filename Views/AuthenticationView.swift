import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
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
                    do {
                        try await authViewModel.handleAppleSignIn(result)
                    } catch {
                        showError = true
                        errorMessage = error.localizedDescription
                    }
                }
            }
            .frame(height: 44)
            .cornerRadius(8)
            
            // Google Sign In
            Button {
                Task {
                    do {
                        try await authViewModel.signInWithGoogle()
                    } catch {
                        showError = true
                        errorMessage = error.localizedDescription
                    }
                }
            } label: {
                HStack {
                    Image("google_logo") // Add this image to assets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("Sign in with Google")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(8)
            }
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