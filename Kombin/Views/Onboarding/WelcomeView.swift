import SwiftUI

struct WelcomeView: View {
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Hanger icon
            Image(systemName: "tshirt")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .padding(.bottom, AppTheme.Spacing.xl)
            
            // App name
            Text(LocalizedStringKey("welcome_title"))
                .font(.system(size: 42, weight: .bold, design: .default))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .padding(.bottom, AppTheme.Spacing.sm)
            
            // Tagline
            Text(LocalizedStringKey("welcome_subtitle"))
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Spacer()
            Spacer()
            
            // Get Started button
            Button(action: onContinue) {
                Text(LocalizedStringKey("welcome_button"))
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.buttonText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.lg)
                    .background(AppTheme.Colors.buttonFill)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            }
            .padding(.horizontal, AppTheme.Spacing.xl)
            .padding(.bottom, AppTheme.Spacing.xxxl)
        }
        .background(AppTheme.Colors.background)
    }
}

#Preview {
    WelcomeView(onContinue: {})
}
