import SwiftUI

struct ProfileSetupView: View {
    @Binding var name: String
    @Binding var gender: Gender
    @Binding var birthYear: Int
    let onContinue: () -> Void
    
    private let yearRange = Array(1950...2015).reversed().map { $0 }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxl) {
                // Title
                Text(LocalizedStringKey("profile_title"))
                    .font(AppTheme.Typography.title1)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .padding(.top, AppTheme.Spacing.xxxl)
                
                // Avatar placeholder
                HStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                            .foregroundColor(AppTheme.Colors.border)
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "camera")
                            .font(.system(size: 28))
                            .foregroundColor(AppTheme.Colors.textTertiary)
                    }
                    Spacer()
                }
                
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
                    Text(LocalizedStringKey("gender_male"))
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .hidden() // Just for spacing reference
                        .overlay(alignment: .leading) {
                            Text("Cinsiyet")
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
                
                // Birth Year
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Text(LocalizedStringKey("birth_year"))
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    Menu {
                        ForEach(yearRange, id: \.self) { year in
                            Button("\(year)") {
                                birthYear = year
                            }
                        }
                    } label: {
                        HStack {
                            Text("\(birthYear)")
                                .font(AppTheme.Typography.body)
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(AppTheme.Typography.caption1)
                                .foregroundColor(AppTheme.Colors.textTertiary)
                        }
                        .padding(.vertical, AppTheme.Spacing.md)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .background(AppTheme.Colors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                                .stroke(AppTheme.Colors.border, lineWidth: 1)
                        )
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
        name: .constant("Mehmet"),
        gender: .constant(.male),
        birthYear: .constant(1995),
        onContinue: {}
    )
}
