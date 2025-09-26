//
//  LoginView.swift
//  larry-ios
//
//  Created by AI Assistant on 9/25/25.
//

import SwiftUI
import AuthenticationServices

private enum AuthMode {
    case landing
    case signInOptions
    case emailSignIn
    case emailSignUp
}

/// Login screen staged like reference mock with animated expansions
struct LoginView: View {
    @EnvironmentObject private var authManager: AuthManager

    @State private var mode: AuthMode = .landing
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var showingError = false
    @State private var errorMessage = ""

    private let transitionStyle = AnyTransition.move(edge: .bottom).combined(with: .opacity)

    var body: some View {
        ZStack {
            background

            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        Spacer().frame(height: geometry.size.height * 0.1)

                        header

                        Spacer().frame(height: geometry.size.height * 0.06)

                        contentSection

                        if mode == .landing {
                            debugControls
                        }

                        legalCopy
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .ignoresSafeArea()
        .alert("Sign In Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onChange(of: authManager.authState) { _, newValue in
            if case .error(let message) = newValue {
                errorMessage = message
                showingError = true
            }
        }
    }

    // MARK: - Sections

    private var background: some View {
        LinearGradient(
            colors: [Color(.black).opacity(0.82), Color(.black).opacity(0.9)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var header: some View {
        VStack(spacing: 18) {
            icon
                .transition(.opacity)

            VStack(spacing: 6) {
                Text("Welcome to Larry")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Your AI-powered vocabulary coach")
                    .font(.headline)
                    .foregroundColor(Color.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var icon: some View {
        Group {
            switch mode {
            case .landing:
                Circle()
                    .fill(Color.blue)
                    .frame(width: 88, height: 88)
                    .overlay {
                        Text("L")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
            case .signInOptions:
                Image(systemName: "sparkle")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.white)
            case .emailSignIn:
                Image(systemName: "mail.fill")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.white)
            case .emailSignUp:
                Image(systemName: "sparkles")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: mode)
    }

    @ViewBuilder
    private var contentSection: some View {
        switch mode {
        case .landing:
            landingButtons
                .transition(transitionStyle)
        case .signInOptions:
            signInOptions
                .transition(transitionStyle)
        case .emailSignIn:
            emailForm(
                title: "Sign In",
                subtitle: "Enter your details to continue.",
                primaryTitle: "Sign In",
                secondaryTitle: "Create Account",
                showConfirmField: false,
                primaryAction: handleEmailSignIn,
                secondaryAction: { animate(to: .emailSignUp) }
            )
            .transition(transitionStyle)
        case .emailSignUp:
            emailForm(
                title: "Create Account",
                subtitle: "Create your Larry account in seconds.",
                primaryTitle: "Create Account",
                secondaryTitle: "Sign In",
                showConfirmField: true,
                primaryAction: handleEmailSignUp,
                secondaryAction: { animate(to: .emailSignIn) }
            )
            .transition(transitionStyle)
        }
    }

    private var landingButtons: some View {
        VStack(spacing: 16) {
            Button {
                animate(to: .emailSignUp)
            } label: {
                Text("Create account")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }

            Button {
                animate(to: .signInOptions)
            } label: {
                Text("Sign in")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .foregroundColor(.white)
            }
        }
    }

    private var signInOptions: some View {
        VStack(spacing: 16) {
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                Task { await handleAppleSignInResult(result) }
            }
            .signInWithAppleButtonStyle(.white)
            .frame(height: 56)
            .clipShape(Capsule())

            providerButton(
                title: "Sign in with Google",
                image: "google",
                background: Color.white,
                foreground: Color.black
            ) {
                Task { await handleGoogleSignIn() }
            }

            providerButton(
                title: "Sign in with Email",
                image: "envelope.fill",
                background: Color.purple,
                foreground: .white
            ) {
                animate(to: .emailSignIn)
            }

            Button("Back") {
                animate(to: .landing, resetFields: true)
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.top, 8)
        }
    }

    private func providerButton(title: String,
                                 image: String,
                                 background: Color,
                                 foreground: Color,
                                 action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if image == "google" {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 24, height: 24)
                        .overlay {
                            Text("G")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.blue)
                        }
                } else {
                    Image(systemName: image)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(foreground)
                }

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(foreground)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal, 20)
            .frame(height: 56)
            .background(background)
            .clipShape(Capsule())
        }
    }

    private func emailForm(title: String,
                            subtitle: String,
                            primaryTitle: String,
                            secondaryTitle: String,
                            showConfirmField: Bool,
                            primaryAction: @escaping () -> Void,
                            secondaryAction: @escaping () -> Void) -> some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(Color.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                inputField(icon: "envelope.fill", placeholder: "john.doe@example.com", text: $email, isSecure: false, contentType: .emailAddress)

                inputField(icon: "lock.fill", placeholder: "SecurePassword123!", text: $password, isSecure: true, contentType: .password)

                if showConfirmField {
                    inputField(icon: "lock.rotation", placeholder: "Re-enter password", text: $confirmPassword, isSecure: true, contentType: .password)
                }
            }

            VStack(spacing: 12) {
                Button(action: primaryAction) {
                    Text(primaryTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
                .disabled(!isPrimaryEnabled(showConfirmField: showConfirmField) || authManager.authState.isLoading)

                Button(action: secondaryAction) {
                    Text(secondaryTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .foregroundColor(.white)
                        .overlay {
                            Capsule()
                                .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
                        }
                }
                .disabled(authManager.authState.isLoading)

                Button("Back") {
                    animate(to: .landing, resetFields: true)
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
                .padding(.top, 4)
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private func inputField(icon: String,
                             placeholder: String,
                             text: Binding<String>,
                             isSecure: Bool,
                             contentType: UITextContentType) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(Color.white.opacity(0.7))

            Group {
                if isSecure {
                    SecureField(placeholder, text: text)
                } else {
                    TextField(placeholder, text: text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .foregroundColor(.white)
            .textContentType(contentType)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(Color.white.opacity(0.12))
        .clipShape(Capsule())
    }

    private var debugControls: some View {
        #if DEBUG
        Button("Clear Auth Data (Debug)") {
            authManager.clearAllAuthData()
            authManager.forceRefreshAuthState()
        }
        .font(.caption)
        .foregroundColor(.red)
        #else
        EmptyView()
        #endif
    }

    private var legalCopy: some View {
        VStack(spacing: 6) {
            Text("By tapping 'Sign in' / 'Create account', you agree to our")
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.65))
            HStack(spacing: 12) {
                Button("Terms of Service") {}
                    .font(.caption)
                Button("Privacy Policy") {}
                    .font(.caption)
                Button("Cookies Policy") {}
                    .font(.caption)
            }
            .foregroundColor(.white)
            .underline()
        }
        .padding(.top, 8)
    }

    // MARK: - Helpers

    private func animate(to newMode: AuthMode, resetFields: Bool = false) {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85, blendDuration: 0.25)) {
            mode = newMode
            if resetFields {
                clearFields()
            }
        }
    }

    private func clearFields() {
        email = ""
        password = ""
        confirmPassword = ""
    }

    private func isPrimaryEnabled(showConfirmField: Bool) -> Bool {
        guard !email.isEmpty, email.contains("@"), !password.isEmpty else { return false }
        if showConfirmField {
            return !confirmPassword.isEmpty && confirmPassword == password
        }
        return true
    }

    // MARK: - Actions

    private func handleAppleSignInResult(_ result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success(let authorization):
            do {
                try await authManager.handleAppleSignInResult(authorization)
                animate(to: .landing, resetFields: true)
            } catch {
                print("Apple Sign-In error: \(error)")
            }
        case .failure(let error):
            print("Apple Sign-In failed: \(error)")
        }
    }

    private func handleGoogleSignIn() async {
        do {
            try await authManager.signInWithGoogle()
            animate(to: .landing, resetFields: true)
        } catch {
            print("Google Sign-In error: \(error)")
        }
    }

    private func handleEmailSignIn() {
        Task {
            do {
                try await authManager.signInWithEmail(email, password: password)
                animate(to: .landing, resetFields: true)
            } catch {
                print("Email Sign-In error: \(error)")
            }
        }
    }

    private func handleEmailSignUp() {
        Task {
            do {
                guard password == confirmPassword else {
                    errorMessage = "Passwords do not match"
                    showingError = true
                    return
                }
                try await authManager.signUpWithEmail(email, password: password, name: nil)
                animate(to: .landing, resetFields: true)
            } catch {
                print("Email Sign-Up error: \(error)")
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager.shared)
}

