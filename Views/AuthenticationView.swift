import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var isSignUp = true
    
    var body: some View {
        VStack(spacing: 24) {
            // Logo and Title
            VStack(spacing: 16) {
                Image(systemName: "star.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                    .background(Color.black)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                
                Text("Star GO")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.top, 60)
            
            // Main Form
            VStack(spacing: 20) {
                Text(isSignUp ? "Create Account" : "Sign In")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if isSignUp {
                    signUpForm
                } else {
                    signInForm
                }
            }
            .padding(.horizontal, 32)
            
            // Social Sign In Section
            VStack(spacing: 16) {
                Text("or")
                    .foregroundColor(.gray)
                
                socialSignInSection
                
                // Continue as Guest Button
                Button(action: {
                    Task {
                        try await authViewModel.signInAnonymously()
                    }
                }) {
                    Text("Continue as Guest")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                }
                
                // Toggle Sign In/Sign Up
                Button(action: { isSignUp.toggle() }) {
                    Text(isSignUp ? "Already have an account? Sign In" : "Need an account? Sign Up")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
    
    private var signUpForm: some View {
        VStack(spacing: 16) {
            CustomTextField(text: $username, placeholder: "Username", imageName: "person")
            CustomTextField(text: $email, placeholder: "Email", imageName: "envelope")
            CustomTextField(text: $password, placeholder: "Password", imageName: "lock", isSecure: true)
            
            Button(action: {
                Task {
                    try await authViewModel.signUp(email: email, password: password, username: username)
                }
            }) {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
    }
    
    private var signInForm: some View {
        VStack(spacing: 16) {
            CustomTextField(text: $email, placeholder: "Email", imageName: "envelope")
            CustomTextField(text: $password, placeholder: "Password", imageName: "lock", isSecure: true)
            
            Button(action: {
                Task {
                    try await authViewModel.signIn(email: email, password: password)
                }
            }) {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
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
            .frame(height: 44)
            .frame(maxWidth: 280)
            .signInWithAppleButtonStyle(.white)
            
            // Google Sign In Button
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
                    Image("google_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                    Text("Sign in with Google")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "1f1f1f"))
                }
                .frame(maxWidth: 280)
                .frame(height: 44)
                .background(Color.white)
                .cornerRadius(8)
            }
        }
    }
}

// MARK: - Custom Text Field Style
struct CustomTextField: View {
    @Binding var text: String
    var placeholder: String
    var imageName: String
    var isSecure: Bool = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
            }
            
            if isSecure {
                SecureField("", text: $text)
            } else {
                TextField("", text: $text)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
        )
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