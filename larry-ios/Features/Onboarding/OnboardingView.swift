//
//  OnboardingView.swift
//  larry-ios
//
//  Created by AI Assistant on 9/15/25.
//

import SwiftUI

/// Onboarding flow for new users to set up their interests and preferences
struct OnboardingView: View {
    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress indicator
                ProgressView(value: viewModel.progress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                // Content based on current step
                Group {
                    switch viewModel.currentStep {
                    case .welcome:
                        WelcomeStepView()
                    case .identity:
                        IdentityAndGoalsStepView()
                    case .interests:
                        InterestsStepView()
                    case .preferences:
                        PreferencesStepView()
                    case .complete:
                        CompleteStepView()
                    }
                }
                .environmentObject(viewModel)
                
                Spacer()
                
                // Navigation buttons
                HStack(spacing: 16) {
                    if viewModel.canGoBack {
                        Button("Back") {
                            viewModel.goBack()
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    }
                    
                    Button(viewModel.nextButtonTitle) {
                        Task {
                            await viewModel.goNext()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .disabled(!viewModel.canGoNext || viewModel.isLoading)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .navigationTitle("Setup")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
        .alert("Error", isPresented: $viewModel.showingError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

// MARK: - Welcome Step

private struct WelcomeStepView: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // App icon
            Circle()
                .fill(Color.blue.gradient)
                .frame(width: 120, height: 120)
                .overlay {
                    Text("L")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            
            VStack(spacing: 16) {
                Text("Welcome to Larry!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Let's personalize your vocabulary learning experience. We'll ask a few questions to tailor the perfect learning journey for you.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Identity and Goals Step

private struct IdentityAndGoalsStepView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tell us about yourself")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Help us personalize your learning experience")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                
                VStack(alignment: .leading, spacing: 20) {
                    // Name (Required)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name *")
                            .font(.headline)
                        TextField("Enter your name", text: $viewModel.name)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Username (Optional)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Username")
                            .font(.headline)
                        TextField("Choose a username (optional)", text: $viewModel.username)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Current Profession
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Role")
                            .font(.headline)
                        TextField("e.g., Product Manager, Student", text: $viewModel.professionCurrent)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Target Profession
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Target Role")
                            .font(.headline)
                        TextField("e.g., Senior PM, Data Scientist", text: $viewModel.professionTarget)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Goal (Required)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Learning Goal *")
                            .font(.headline)
                        TextField("e.g., Get promoted, Learn new skills", text: $viewModel.goal)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Travel Plans
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Upcoming Travel")
                            .font(.headline)
                        TextField("Destination (optional)", text: $viewModel.travelLocation)
                            .textFieldStyle(.roundedBorder)
                        
                        if !viewModel.travelLocation.isEmpty {
                            DatePicker(
                                "Travel Date",
                                selection: Binding(
                                    get: { viewModel.travelDate ?? Date() },
                                    set: { viewModel.travelDate = $0 }
                                ),
                                displayedComponents: .date
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer(minLength: 100)
            }
            .padding(.vertical, 16)
        }
    }
}

// MARK: - Interests Step

private struct InterestsStepView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What interests you?")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Select at least 3 topics you'd like to learn vocabulary about.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                
                // Custom Topic Input
                VStack(alignment: .leading, spacing: 12) {
                    Text("Add Your Own Topic")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        TextField("Enter a topic (e.g., Photography, Cooking)", text: $viewModel.customTopicText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit {
                                viewModel.addCustomTopic()
                            }
                        
                        Button(action: {
                            viewModel.addCustomTopic()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(viewModel.customTopicText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                        }
                        .disabled(viewModel.customTopicText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding(.horizontal, 16)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(viewModel.availableTopics, id: \.id) { topic in
                        TopicSelectionCard(
                            topic: topic,
                            isSelected: viewModel.selectedTopics.contains(topic.id)
                        ) {
                            viewModel.toggleTopic(topic.id)
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                if !viewModel.selectedTopics.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Selected: \(viewModel.selectedTopics.count) topics")
                            .font(.headline)
                            .foregroundColor(viewModel.selectedTopics.count >= 3 ? .green : .orange)
                        
                        if viewModel.selectedTopics.count < 3 {
                            Text("Select at least 3 topics to continue")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                Spacer(minLength: 100)
            }
            .padding(.vertical, 16)
        }
    }
}

// MARK: - Preferences Step

private struct PreferencesStepView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Learning Preferences")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Customize your learning experience")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 24) {
                    // Difficulty preference
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Preferred Difficulty")
                            .font(.headline)
                        
                        Picker("Difficulty", selection: $viewModel.preferredDifficulty) {
                            ForEach(Term.DifficultyLevel.allCases, id: \.self) { difficulty in
                                Text(difficulty.displayName)
                                    .tag(difficulty)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Notifications
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Daily Reminders")
                            .font(.headline)
                        
                        Toggle("Enable daily word notifications", isOn: $viewModel.enableNotifications)
                        
                        if viewModel.enableNotifications {
                            DatePicker(
                                "Preferred time",
                                selection: $viewModel.notificationTime,
                                displayedComponents: .hourAndMinute
                            )
                            .padding(.leading, 16)
                        }
                    }
                    
                    // Learning goals
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Daily Goal")
                            .font(.headline)
                        
                        Text("Words per day: \(Int(viewModel.dailyWordGoal))")
                            .foregroundColor(.secondary)
                        
                        Slider(
                            value: $viewModel.dailyWordGoal,
                            in: 1...5,
                            step: 1
                        )
                    }
                }
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }
}

// MARK: - Complete Step

private struct CompleteStepView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            VStack(spacing: 16) {
                if viewModel.isPreparingFirstWord {
                    Text("Preparing your first word...")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("We're generating personalized vocabulary based on your selected topics. This may take a moment.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                } else if viewModel.firstWordReady {
                    Text("You're all set!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Larry is ready to help you learn new vocabulary tailored to your interests. Your first word is waiting!")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                } else {
                    Text("You're all set!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Larry is ready to help you learn new vocabulary tailored to your interests.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
            }
            
            if viewModel.isLoading {
                ProgressView("Finalizing setup...")
                    .padding(.top, 16)
            } else if viewModel.isPreparingFirstWord {
                ProgressView("Generating your first vocabulary word...")
                    .padding(.top, 16)
            }
            
            if let firstWordError = viewModel.firstWordError {
                Text("⚠️ \(firstWordError)")
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Supporting Views

private struct TopicSelectionCard: View {
    let topic: Topic
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: topic.category.systemImageName)
                    .foregroundColor(isSelected ? .white : .blue)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            
            Text(topic.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .primary)
                .lineLimit(2)
            
            Text(topic.description)
                .font(.caption)
                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                .lineLimit(2)
        }
        .padding(12)
        .background(isSelected ? Color.blue : Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .onTapGesture {
            onToggle()
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AuthManager.shared)
}

