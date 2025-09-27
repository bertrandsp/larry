//
//  OnboardingView.swift
//  larry-ios
//
//  Created by AI Assistant on 9/15/25.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    header
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            stepContent
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 12)
                    }
                    .scrollDisabled(viewModel.currentStep != .topics)
                    
                    footer
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden)
        }
        .alert("Error", isPresented: $viewModel.showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProgressView(value: viewModel.progress)
                .progressViewStyle(.linear)
                .tint(.accentColor)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.currentStep.title)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.primary)
                if let subtitle = viewModel.currentStep.subtitle {
                    Text(subtitle)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case .welcome:
            WelcomeCard()
        case .dailyGoal:
            DailyGoalCard(goal: $viewModel.dailyWordGoal)
        case .weekPreview:
            WeekPreviewCard()
        case .source:
            SourceSelectionView(selected: $viewModel.onboardingSource)
        case .skillLevel:
            SkillLevelView(selected: $viewModel.learningLevel)
        case .widgetPrompt:
            WidgetPromptView(selected: $viewModel.widgetOptIn)
        case .motivation:
            MotivationCard()
        case .topics:
            TopicsSelectionView(
                topics: viewModel.availableTopics,
                selectedTopics: $viewModel.selectedTopics,
                customTopicText: $viewModel.customTopicText,
                onAddCustomTopic: viewModel.addCustomTopic
            )
        case .complete:
            CompleteStepView()
        }
    }
    
    private var footer: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                if viewModel.canGoBack {
                    Button("Back") {
                        viewModel.goBack()
                    }
                    .buttonStyle(SecondaryOnboardingButtonStyle())
                }
                
                Button(viewModel.nextButtonTitle) {
                    Task {
                        await viewModel.goNext()
                    }
                }
                .buttonStyle(PrimaryOnboardingButtonStyle())
                .disabled(!viewModel.canGoNext || viewModel.isLoading)
            }
        }
    }
}

// MARK: - Styles

private struct PrimaryOnboardingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.accentColor.cornerRadius(16))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

private struct SecondaryOnboardingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.accentColor)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.accentColor, lineWidth: 2)
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

private struct OnboardingCard<Content: View>: View {
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content()
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 6)
    }
}

// MARK: - Step Views

private struct WelcomeCard: View {
    var body: some View {
        OnboardingCard {
        VStack(spacing: 12) {
            Image("onboarding-welcome")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 220)
                .accessibilityHidden(true)
            
            VStack(spacing: 8) {
                Text("Hi there! I'm Larry.")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Let's get your vocabulary journey started!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
            .frame(maxWidth: .infinity)
        }
    }
}

private struct DailyGoalCard: View {
    @Binding var goal: Int
    
    var body: some View {
        OnboardingCard {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("What's your daily learning goal?", systemImage: "target")
                        .font(.headline)
                    Text("Consistency is key to mastering new vocabulary.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack(alignment: .lastTextBaseline, spacing: 8) {
                    Text("\(goal)")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundColor(.accentColor)
                    Text("words per day")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Slider(
                    value: Binding(
                        get: { Double(goal) },
                        set: { goal = Int($0) }
                    ),
                    in: 1...10,
                    step: 1
                )
                .tint(.accentColor)
                
                Text("Small steps every day lead to big results. Let's make learning a habit!")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }
}

private struct WeekPreviewCard: View {
    var body: some View {
        OnboardingCard {
            VStack(spacing: 16) {
                Image("onboarding-week-preview")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 220)
                    .accessibilityHidden(true)
                
                Text("You're all set for a fantastic first week!")
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Great! In your first week, you'll master core terms, build a solid foundation, and unlock new confidence in speaking English. Larry is excited to guide you!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

private struct SourceSelectionView: View {
    @Binding var selected: OnboardingViewModel.OnboardingSourceOption?
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(OnboardingViewModel.OnboardingSourceOption.allCases) { option in
                SelectableRow(
                    title: option.title,
                    subtitle: subtitle(for: option),
                    systemIcon: option.iconName,
                    isSelected: selected == option
                ) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selected = option
                    }
                }
            }
        }
    }
    
    private func subtitle(for option: OnboardingViewModel.OnboardingSourceOption) -> String {
        switch option {
        case .appStore: return "Found us on the App Store"
        case .friend: return "Recommended by a friend"
        case .social: return "Saw us on social media"
        case .search: return "Discovered via online search"
        case .other: return "Another source"
        }
    }
}

private struct SkillLevelView: View {
    @Binding var selected: OnboardingViewModel.LearningLevelOption?
    
    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 16)]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(OnboardingViewModel.LearningLevelOption.allCases) { option in
                SelectableCard(
                    title: option.title,
                    subtitle: option.subtitle,
                    systemIcon: option.iconName,
                    isSelected: selected == option
                ) {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                        selected = option
                    }
                }
            }
        }
    }
}

private struct WidgetPromptView: View {
    @Binding var selected: Bool?
    
    var body: some View {
        OnboardingCard {
            VStack(spacing: 18) {
                Image("onboarding-widget")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 220)
                    .accessibilityHidden(true)
                
                Text("Daily Vocabulary On Your Home Screen?")
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Get new words delivered directly to your home screen every day. A quick glance is all it takes to boost your vocabulary!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 12) {
                    Button {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                            selected = true
                        }
                    } label: {
                        Text("Add Widget")
                    }
                    .buttonStyle(PrimaryOnboardingButtonStyle())
                    
                    Button {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                            selected = false
                        }
                    } label: {
                        Text("Not Now")
                    }
                    .buttonStyle(SecondaryOnboardingButtonStyle())
                }
            }
        }
    }
}

private struct MotivationCard: View {
    var body: some View {
        OnboardingCard {
            VStack(spacing: 16) {
                Image("onboarding-motivation")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 220)
                    .accessibilityHidden(true)
                
                Text("Ready for a transformation?")
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 12) {
                    MotivationRow(text: "A stronger vocabulary bank, enriched with practical words")
                    MotivationRow(text: "Boosted speaking confidence to articulate your thoughts effortlessly")
                    MotivationRow(text: "A consistent learning habit, making progress daily")
                }
            }
        }
    }
}

private struct TopicsSelectionView: View {
    let topics: [Topic]
    @Binding var selectedTopics: Set<String>
    @Binding var customTopicText: String
    let onAddCustomTopic: () -> Void
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            OnboardingCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Add Your Own Topic")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        TextField("e.g., Photography, Cooking", text: $customTopicText)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit(onAddCustomTopic)
                        
                        Button(action: onAddCustomTopic) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(customTopicText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .accentColor)
                        }
                        .disabled(customTopicText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    
                    Text("Select at least 3 topics")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(topics) { topic in
                    TopicChip(
                        topic: topic,
                        isSelected: selectedTopics.contains(topic.id)
                    ) {
                        toggle(topic.id)
                    }
                }
            }
            
            if !selectedTopics.isEmpty {
                Text("Selected: \(selectedTopics.count) topics")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(selectedTopics.count >= 3 ? .accentColor : .orange)
            }
        }
    }
    
    private func toggle(_ id: String) {
        if selectedTopics.contains(id) {
            selectedTopics.remove(id)
        } else {
            selectedTopics.insert(id)
        }
    }
}

private struct TopicChip: View {
    let topic: Topic
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                action()
            }
        }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: topic.category.systemImageName)
                        .foregroundColor(isSelected ? .white : .accentColor)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                    }
                }
                
                Text(topic.name)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(2)
                
                Text(topic.description)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .lineLimit(2)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.accentColor : Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 4)
        }
    }
}

private struct SelectableRow: View {
    let title: String
    let subtitle: String
    let systemIcon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: systemIcon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                    .frame(width: 28)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                }
            }
            .padding(16)
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                    )
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
        }
    }
}

private struct SelectableCard: View {
    enum Style {
        case vertical
        case horizontal
    }
    
    let title: String
    let subtitle: String
    let systemIcon: String
    let isSelected: Bool
    var style: Style = .vertical
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: systemIcon)
                        .font(.title3)
                        .foregroundColor(isSelected ? .white : .accentColor)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isSelected ? Color.white.opacity(0.2) : Color.accentColor.opacity(0.12))
                        )
                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(isSelected ? .white : .primary)
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                }
                
                if isSelected {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.accentColor : Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
        }
    }
}

private struct MotivationRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(.accentColor)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

private struct CompleteStepView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            Text("You're all set!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Your personalized vocabulary journey is ready to begin.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AuthManager.shared)
}

