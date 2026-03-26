import SwiftUI

// MARK: - App Theme

struct AppTheme {
    
    // MARK: - Colors
    
    struct Colors {
        // Backgrounds
        static let background = Color("Background")
        static let cardBackground = Color("CardBackground")
        static let elevatedBackground = Color("ElevatedBackground")
        
        // Text
        static let textPrimary = Color("TextPrimary")
        static let textSecondary = Color("TextSecondary")
        static let textTertiary = Color("TextTertiary")
        
        // Interactive
        static let accent = Color("AccentColor")
        static let buttonFill = Color("ButtonFill")
        static let buttonText = Color("ButtonText")
        
        // Borders
        static let border = Color("BorderColor")
        static let borderStrong = Color("BorderStrong")
        
        // Tab bar
        static let tabActive = Color("TabActive")
        static let tabInactive = Color("TabInactive")
        
        // Status
        static let success = Color("Success")
        static let warning = Color("Warning")
        static let error = Color("Error")
    }
    
    // MARK: - Typography
    
    struct Typography {
        // Large titles
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .default)
        static let title1 = Font.system(size: 28, weight: .bold, design: .default)
        static let title2 = Font.system(size: 22, weight: .bold, design: .default)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .default)
        
        // Body
        static let headline = Font.system(size: 17, weight: .semibold, design: .default)
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let callout = Font.system(size: 16, weight: .regular, design: .default)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
        
        // Small
        static let footnote = Font.system(size: 13, weight: .regular, design: .default)
        static let caption1 = Font.system(size: 12, weight: .regular, design: .default)
        static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
    }
    
    // MARK: - Spacing
    
    struct Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    
    struct Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let full: CGFloat = 100
    }
    
    // MARK: - Shadows
    
    struct Shadow {
        static let card = SwiftUI.Color.black.opacity(0.04)
        static let elevated = SwiftUI.Color.black.opacity(0.08)
    }
}

// MARK: - Color Extension for Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String {
        let components = UIColor(self).cgColor.components ?? [0, 0, 0, 1]
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

// MARK: - Card Style Modifier

struct CardStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(AppTheme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(AppTheme.Colors.border, lineWidth: 1)
            )
    }
}

// MARK: - Dashed Card Style

struct DashedCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                    .foregroundColor(AppTheme.Colors.border)
            )
    }
}

// MARK: - Pill Button Style

struct PillButtonStyle: ViewModifier {
    let isSelected: Bool
    
    func body(content: Content) -> some View {
        content
            .font(AppTheme.Typography.subheadline)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(isSelected ? AppTheme.Colors.buttonFill : Color.clear)
            .foregroundColor(isSelected ? AppTheme.Colors.buttonText : AppTheme.Colors.textSecondary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : AppTheme.Colors.border, lineWidth: 1)
            )
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
    
    func dashedCardStyle() -> some View {
        modifier(DashedCardStyle())
    }
    
    func pillStyle(isSelected: Bool) -> some View {
        modifier(PillButtonStyle(isSelected: isSelected))
    }
}
