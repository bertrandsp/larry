//
//  EmailAuthView.swift
//  larry-ios
//
//  Created by AI Assistant on 9/25/25.
//

import SwiftUI

/// Email/Password authentication form presented inline on the login screen
struct EmailAuthView: View {
    @Binding var isSignUp: Bool
    @Binding var email: String
    @Binding var password: String
    @Binding var name: String
    let onSubmit: (String, String, String?) -> Void
    let onCancel: () -> Void
    let onToggleMode: () -> Void
    
    @EnvironmentObject private var authManager: AuthManager
    @State private var isSecurePassword = true
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case name, email, password
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(isSignUp ? "Create an account" : "Sign in with email")
                    .font(.headline)
                Spacer()
                Button(action: onCancel) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .accessibilityLabel("Close email sign-in form")
            }
            
            if isSignUp {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Name")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    TextField("Enter your name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.name)
                        .autocapitalization(.words)
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .email }
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Email")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                TextField("Enter your email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Password")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack {
                    Group {
                        if isSecurePassword {
                            SecureField("Enter your password", text: $password)
                        } else {
                            TextField("Enter your password", text: $password)
                        }
                    }
                    .textContentType(isSignUp ? .newPassword : .password)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.done)
                    .onSubmit { handleSubmit() }
                    
                    Button(action: { isSecurePassword.toggle() }) {
                        Image(systemName: isSecurePassword ? "eye.slash" : "eye")
                            .foregroundColor(.secondary)
                    }
                }
                .textFieldStyle(.roundedBorder)
            }
            
            if isSignUp {
                Text("Password should be at least 6 characters long")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Button(action: handleSubmit) {
                HStack {
                    if authManager.authState.isLoading {
                        ProgressView()
                            .scaleEffect(0.9)
                            .foregroundColor(.white)
                    } else {
                        Text(isSignUp ? "Create Account" : "Sign In")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .foregroundColor(.white)
                .background(isFormValid ? (isSignUp ? Color.green : Color.blue) : Color.gray)
                .cornerRadius(26)
            }
            .disabled(!isFormValid || authManager.authState.isLoading)
            
            Button(action: onToggleMode) {
                HStack(spacing: 4) {
                    Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                        .foregroundColor(.secondary)
                    Text(isSignUp ? "Sign In" : "Create Account")
                        .fontWeight(.medium)
                        .foregroundColor(isSignUp ? .blue : .green)
                }
                .font(.subheadline)
            }
            .disabled(authManager.authState.isLoading)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focusedField = isSignUp ? .name : .email
            }
        }
    }
    
    private var isFormValid: Bool {
        let emailValid = !email.isEmpty && email.contains("@")
        let passwordValid = password.count >= 6
        let nameValid = !isSignUp || !name.isEmpty
        return emailValid && passwordValid && nameValid
    }
    
    private func handleSubmit() {
        guard isFormValid else { return }
        let submitName = isSignUp ? (name.isEmpty ? nil : name) : nil
        onSubmit(email, password, submitName)
    }
}

#Preview("Sign In") {
    EmailAuthView(
        isSignUp: .constant(false),
        email: .constant(""),
        password: .constant(""),
        name: .constant(""),
        onSubmit: { _, _, _ in },
        onCancel: { },
        onToggleMode: { }
    )
    .environmentObject(AuthManager.shared)
}

#Preview("Sign Up") {
    EmailAuthView(
        isSignUp: .constant(true),
        email: .constant(""),
        password: .constant(""),
        name: .constant(""),
        onSubmit: { _, _, _ in },
        onCancel: { },
        onToggleMode: { }
    )
    .environmentObject(AuthManager.shared)
}
