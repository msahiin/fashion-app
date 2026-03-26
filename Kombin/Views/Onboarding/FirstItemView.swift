import SwiftUI

struct FirstItemView: View {
    let onAddPhoto: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: AppTheme.Spacing.sm) {
                Text(LocalizedStringKey("first_item_title"))
                    .font(AppTheme.Typography.title1)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(LocalizedStringKey("first_item_subtitle"))
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, AppTheme.Spacing.xxxl)
            
            // Photo options
            HStack(spacing: AppTheme.Spacing.lg) {
                // Take Photo
                Button(action: onAddPhoto) {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        Image(systemName: "camera")
                            .font(.system(size: 36, weight: .light))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        Text(LocalizedStringKey("take_photo"))
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .background(AppTheme.Colors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                            .stroke(AppTheme.Colors.border, lineWidth: 1)
                    )
                }
                
                // From Gallery
                Button(action: onAddPhoto) {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        Image(systemName: "photo")
                            .font(.system(size: 36, weight: .light))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        Text(LocalizedStringKey("from_gallery"))
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .background(AppTheme.Colors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                            .stroke(AppTheme.Colors.border, lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, AppTheme.Spacing.xl)
            
            Spacer()
            
            // Skip link
            Button(action: onSkip) {
                Text(LocalizedStringKey("skip_for_now"))
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .padding(.bottom, AppTheme.Spacing.xxxl)
        }
        .background(AppTheme.Colors.background)
    }
}

#Preview {
    FirstItemView(onAddPhoto: {}, onSkip: {})
}
