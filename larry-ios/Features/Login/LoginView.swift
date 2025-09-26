//
//  LoginView.swift
//  larry-ios
//
//  Created by AI Assistant on 9/25/25.
//

import SwiftUI
import AuthenticationServices

private enum AuthMode {
    case providers
    case emailSignIn
    case emailSignUp
}

/// Login screen recreated to match latest product mock
struct LoginView: View {
    @EnvironmentObject private var authManager: AuthManager

    @State private var mode: AuthMode = .providers
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var showingError = false
    @State private var errorMessage = ""

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: geometry.size.height * 0.08)

                    header

                    Spacer().frame(height: geometry.size.height * 0.06)

                    content

                    if mode == .providers {
                        debugControls
                    }

                    footerLegal
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemBackground))
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

    private var header: some View {
        VStack(spacing: 20) {
            icon

            VStack(spacing: 6) {
                Text("Welcome to Larry")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("Your AI-powered vocabulary coach")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var icon: some View {
        Group {
            switch mode {
            case .providers:
                Circle()
                    .fill(Color.blue)
                    .frame(width: 88, height: 88)
                    .overlay {
                        Text("L")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
            case .emailSignIn:
                Image(systemName: "sparkle")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.blue)
            case .emailSignUp:
                Image(systemName: "sparkles")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.green)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: mode)
    }

    @ViewBuilder
    private var content: some View {
        switch mode {
        case .providers:
            providerOptions

        case .emailSignIn:
            emailForm(title: "Sign In",
                      primaryActionTitle: "Sign In",
                      secondaryActionTitle: "Create Account",
                      showConfirmField: false,
                      primaryAction: handleEmailSignIn,
                      secondaryAction: { withAnimation(.spring()) { mode = .emailSignUp } })

        case .emailSignUp:
            emailForm(title: "Create Account",
                      primaryActionTitle: "Create Account",
                      secondaryActionTitle: "Sign In",
                      showConfirmField: true,
                      primaryAction: handleEmailSignUp,
                      secondaryAction: { withAnimation(.spring()) { mode = .emailSignIn } })
        }
    }

    private var providerOptions: some View {
        VStack(spacing: 16) {
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                Task { await handleAppleSignInResult(result) }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 56)
            .cornerRadius(28)

            Button {
                Task { await handleGoogleSignIn() }
            } label: {
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 24, height: 24)
                        .overlay {
                            Text("G")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.blue)
                        }
                    Text("Continue with Google")
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(.systemBackground))
                .overlay {
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                }
            }
            .cornerRadius(28)
            .disabled(authManager.authState.isLoading)

            Button {
                withAnimation(.spring()) {
                    mode = .emailSignIn
                }
            } label: {
                Text("Sign In with Email")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            }
            .buttonStyle(.plain)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(28)
            .disabled(authManager.authState.isLoading)
        }
    }

    private func emailForm(title: String,
                           primaryActionTitle: String,
                           secondaryActionTitle: String,
                           showConfirmField: Bool,
                           primaryAction: @escaping () -> Void,
                           secondaryAction: @escaping () -> Void) -> some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(mode == .emailSignIn ? "Enter your details to continue." : "Create your Larry account in seconds.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
                    Text(primaryActionTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(26)
                }
                .disabled(!isPrimaryActionEnabled(showConfirmField: showConfirmField) || authManager.authState.isLoading)

                Button(action: secondaryAction) {
                    Text(secondaryActionTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .foregroundColor(.green)
                        .overlay {
                            RoundedRectangle(cornerRadius: 26)
                                .stroke(Color.green, lineWidth: 2)
                        }
                }
                .disabled(authManager.authState.isLoading)

                Button("Forgot Password?") {
                    // TODO: Hook up password reset flow
                }
                .font(.footnote)
                .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(alignment: .topTrailing) {
            Button {
                withAnimation(.spring()) {
                    mode = .providers
                    clearEmailFields()
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .padding(12)
            }
            .accessibilityLabel("Close email form")
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func inputField(icon: String,
                            placeholder: String,
                            text: Binding<String>,
                            isSecure: Bool,
                            contentType: UITextContentType) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.secondary)

            Group {
                if isSecure {
                    SecureField(placeholder, text: text)
                } else {
                    TextField(placeholder, text: text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .textContentType(contentType)
        }
        .padding(.horizontal, 12)
        .frame(height: 48)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var debugControls: some View {
        Button("Clear Auth Data (Debug)") {
            authManager.clearAllAuthData()
            authManager.forceRefreshAuthState()
        }
        .font(.caption)
        .foregroundColor(.red)
    }

    private var footerLegal: some View {
        VStack(spacing: 4) {
            Text("By continuing, you agree to our")
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(spacing: 12) {
                Button("Terms of Service") {}
                    .font(.caption)
                Button("Privacy Policy") {}
                    .font(.caption)
            }
        }
    }

    // MARK: - Helpers

    private func isPrimaryActionEnabled(showConfirmField: Bool) -> Bool {
        guard !email.isEmpty, email.contains("@"), !password.isEmpty else { return false }
        if showConfirmField {
            return password == confirmPassword && !confirmPassword.isEmpty
        }
        return true
    }

    private func clearEmailFields() {
        email = ""
        password = ""
        confirmPassword = ""
    }

    // MARK: - Actions

    private func handleAppleSignInResult(_ result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success(let authorization):
            do {
                try await authManager.handleAppleSignInResult(authorization)
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
        } catch {
            print("Google Sign-In error: \(error)")
        }
    }

    private func handleEmailSignIn() {
        Task {
            do {
                try await authManager.signInWithEmail(email, password: password)
                clearEmailFields()
                mode = .providers
            } catch {
                print("Email sign in error: \(error)")
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
                clearEmailFields()
                mode = .providers
            } catch {
                print("Email sign up error: \(error)")
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager.shared)
}

