import SwiftUI

struct StylePickerView: View {
    @Binding var selectedStyles: [StylePreference]
    let onContinue: () -> Void
    
    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.Spacing.md),
        GridItem(.flexible(), spacing: AppTheme.Spacing.md)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(LocalizedStringKey("style_title"))
                    .font(AppTheme.Typography.title1)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text(LocalizedStringKey("style_subtitle"))
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppTheme.Spacing.xl)
            .padding(.top, AppTheme.Spacing.xxxl)
            .padding(.bottom, AppTheme.Spacing.xl)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: AppTheme.Spacing.md) {
                    ForEach(StylePreference.allCases, id: \.self) { style in
                        StyleCard(
                            style: style,
                            isSelected: selectedStyles.contains(style),
                            onTap: { toggleStyle(style) }
                        )
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
            }
            
            // Continue button
            Button(action: onContinue) {
                Text(LocalizedStringKey("continue_button"))
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.buttonText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.lg)
                    .background(selectedStyles.isEmpty
                                ? AppTheme.Colors.textTertiary
                                : AppTheme.Colors.buttonFill)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            }
            .disabled(selectedStyles.isEmpty)
            .padding(.horizontal, AppTheme.Spacing.xl)
            .padding(.vertical, AppTheme.Spacing.xl)
        }
        .background(AppTheme.Colors.background)
    }
    
    private func toggleStyle(_ style: StylePreference) {
        withAnimation(.easeInOut(duration: 0.15)) {
            if selectedStyles.contains(style) {
                selectedStyles.removeAll { $0 == style }
            } else {
                selectedStyles.append(style)
            }
        }
    }
}

// MARK: - Style Card

struct StyleCard: View {
    let style: StylePreference
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: style.icon)
                    .font(.system(size: 32))
                
                Text(LocalizedStringKey(style.displayKey))
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(AppTheme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(
                        isSelected ? AppTheme.Colors.textPrimary : AppTheme.Colors.border,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(AppTheme.Typography.caption1)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .padding(AppTheme.Spacing.sm)
                }
            }
        }
    }
}

#Preview {
    StylePickerView(selectedStyles: .constant([.casual, .minimalist]), onContinue: {})
}
