import SwiftUI

struct ProfileSetupView: View {
    @Binding var name: String
    @Binding var gender: Gender
    let onContinue: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxl) {
                // Title
                Text(LocalizedStringKey("profile_title"))
                    .font(AppTheme.Typography.title1)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .padding(.top, AppTheme.Spacing.xxxl)
                
                // Name input
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Text(LocalizedStringKey("profile_name"))
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    TextField(LocalizedStringKey("profile_name_placeholder"), text: $name)
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .background(AppTheme.Colors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                                .stroke(AppTheme.Colors.border, lineWidth: 1)
                        )
                }
                
                // Gender selection
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    // Hidden reference for spacing
                    Text(LocalizedStringKey("gender_male"))
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .hidden()
                        .overlay(alignment: .leading) {
                            Text(LocalizedStringKey("gender"))
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                    
                    HStack(spacing: AppTheme.Spacing.md) {
                        ForEach(Gender.allCases, id: \.self) { g in
                            Button(action: { gender = g }) {
                                Text(LocalizedStringKey(g.displayKey))
                                    .pillStyle(isSelected: gender == g)
                            }
                        }
                    }
                }
                
                Spacer(minLength: AppTheme.Spacing.xxxl)
                
                // Continue button
                Button(action: onContinue) {
                    Text(LocalizedStringKey("continue_button"))
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.buttonText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.Spacing.lg)
                        .background(name.isEmpty
                                    ? AppTheme.Colors.textTertiary
                                    : AppTheme.Colors.buttonFill)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                }
                .disabled(name.isEmpty)
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
            .padding(.horizontal, AppTheme.Spacing.xl)
        }
        .background(AppTheme.Colors.background)
    }
}

#Preview {
    ProfileSetupView(
        name: .constant("Alex"),
        gender: .constant(.other),
        onContinue: {}
    )
}
