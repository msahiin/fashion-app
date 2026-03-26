import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @State private var currentStep: OnboardingStep = .welcome
    @State private var userName: String = ""
    @State private var gender: Gender = .other
    @State private var selectedStyles: [StylePreference] = []
    
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case profile = 1
        case style = 2
        case firstItem = 3
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress dots
            if currentStep != .welcome {
                HStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(OnboardingStep.allCases, id: \.rawValue) { step in
                        Circle()
                            .fill(step.rawValue <= currentStep.rawValue
                                  ? AppTheme.Colors.textPrimary
                                  : AppTheme.Colors.border)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, AppTheme.Spacing.lg)
            }
            
            TabView(selection: $currentStep) {
                WelcomeView(onContinue: { nextStep() })
                    .tag(OnboardingStep.welcome)
                
                ProfileSetupView(
                    name: $userName,
                    gender: $gender,
                    onContinue: { nextStep() }
                )
                .tag(OnboardingStep.profile)
                
                StylePickerView(
                    selectedStyles: $selectedStyles,
                    onContinue: { nextStep() }
                )
                .tag(OnboardingStep.style)
                
                FirstItemView(
                    onAddPhoto: { completeOnboarding() },
                    onSkip: { completeOnboarding() }
                )
                .tag(OnboardingStep.firstItem)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: currentStep)
        }
        .background(AppTheme.Colors.background)
    }
    
    private func nextStep() {
        guard let nextIndex = OnboardingStep(rawValue: currentStep.rawValue + 1) else {
            completeOnboarding()
            return
        }
        withAnimation { currentStep = nextIndex }
    }
    
    private func completeOnboarding() {
        // Save user profile
        let user = User(
            name: userName,
            gender: gender,
            selectedStyles: selectedStyles
        )
        modelContext.insert(user)
        
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

#Preview {
    OnboardingContainerView()
}
