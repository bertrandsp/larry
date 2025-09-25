//
//  EmailAuthView.swift
//  larry-ios
//
//  Created by AI Assistant on 9/25/25.
//

import SwiftUI

/// Email/Password authentication view
struct EmailAuthView: View {
    let isSignUp: Bool
    @Binding var email: String
    @Binding var password: String
    @Binding var name: String
    let onSubmit: (String, String, String?) -> Void
    let onCancel: () -> Void
    
    @EnvironmentObject private var authManager: AuthManager
    @State private var isSecurePassword = true
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case name, email, password
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Circle()
                            .fill(isSignUp ? Color.green.gradient : Color.blue.gradient)
                            .frame(width: 80, height: 80)
                            .overlay {
                                Image(systemName: isSignUp ? "person.badge.plus.fill" : "envelope.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                            }
                        
                        VStack(spacing: 8) {
                            Text(isSignUp ? "Create Account" : "Sign In")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text(isSignUp ? "Join Larry to start learning" : "Welcome back to Larry")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 32)
                    
                    // Form
                    VStack(spacing: 16) {
                        // Name field (only for sign up)
                        if isSignUp {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Name")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                TextField("Enter your name", text: $name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .textContentType(.name)
                                    .autocapitalization(.words)
                                    .focused($focusedField, equals: .name)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .email
                                    }
                            }
                        }
                        
                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .email)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .password
                                }
                        }
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            HStack {
                                if isSecurePassword {
                                    SecureField("Enter your password", text: $password)
                                        .textContentType(isSignUp ? .newPassword : .password)
                                        .focused($focusedField, equals: .password)
                                        .submitLabel(.done)
                                        .onSubmit {
                                            handleSubmit()
                                        }
                                } else {
                                    TextField("Enter your password", text: $password)
                                        .textContentType(isSignUp ? .newPassword : .password)
                                        .focused($focusedField, equals: .password)
                                        .submitLabel(.done)
                                        .onSubmit {
                                            handleSubmit()
                                        }
                                }
                                
                                Button(action: {
                                    isSecurePassword.toggle()
                                }) {
                                    Image(systemName: isSecurePassword ? "eye.slash" : "eye")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        if isSignUp {
                            Text("Password should be at least 6 characters long")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Submit button
                    VStack(spacing: 16) {
                        Button(action: handleSubmit) {
                            HStack {
                                if authManager.authState.isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .foregroundColor(.white)
                                } else {
                                    Text(isSignUp ? "Create Account" : "Sign In")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(height: 56)
                            .frame(maxWidth: .infinity)
                            .background(isFormValid ? (isSignUp ? Color.green : Color.blue) : Color.gray)
                            .cornerRadius(28)
                        }
                        .disabled(!isFormValid || authManager.authState.isLoading)
                        
                        // Switch between sign in and sign up
                        Button(action: {
                            // This will be handled by the parent view
                        }) {
                            HStack(spacing: 4) {
                                Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                                    .foregroundColor(.secondary)
                                Text(isSignUp ? "Sign In" : "Create Account")
                                    .fontWeight(.medium)
                                    .foregroundColor(isSignUp ? .blue : .green)
                            }
                            .font(.subheadline)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
            }
        }
        .onAppear {
            // Focus the first field when the view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
        isSignUp: false,
        email: .constant(""),
        password: .constant(""),
        name: .constant(""),
        onSubmit: { _, _, _ in },
        onCancel: { }
    )
    .environmentObject(AuthManager.shared)
}

#Preview("Sign Up") {
    EmailAuthView(
        isSignUp: true,
        email: .constant(""),
        password: .constant(""),
        name: .constant(""),
        onSubmit: { _, _, _ in },
        onCancel: { }
    )
    .environmentObject(AuthManager.shared)
}
