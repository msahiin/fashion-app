import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("appTheme") private var appTheme: String = "system"
    @AppStorage("appLanguage") private var appLanguage: String = "tr"
    @AppStorage("openai_api_key") private var apiKey: String = ""
    @Query private var users: [User]
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    private var currentUser: User? { users.first }
    
    var body: some View {
        List {
            // Profile
            profileSection
            
            // Appearance
            appearanceSection
            
            // Premium
            premiumSection
            
            // AI Settings
            aiSettingsSection
            
            // General
            generalSection
            
            // About
            aboutSection
        }
        .navigationTitle(LocalizedStringKey("settings_title"))
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Profile
    
    private var profileSection: some View {
        Section {
            HStack(spacing: AppTheme.Spacing.lg) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.elevatedBackground)
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(currentUser?.name ?? "")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text(LocalizedStringKey("edit"))
                        .font(AppTheme.Typography.caption1)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Appearance
    
    private var appearanceSection: some View {
        Section(header: Text(LocalizedStringKey("theme_title"))) {
            // Theme picker
            Picker(LocalizedStringKey("theme_title"), selection: $appTheme) {
                Text(LocalizedStringKey("theme_light")).tag("light")
                Text(LocalizedStringKey("theme_dark")).tag("dark")
                Text(LocalizedStringKey("theme_system")).tag("system")
            }
            .pickerStyle(.segmented)
            
            // Language picker
            HStack {
                Text(LocalizedStringKey("language_title"))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Menu {
                    ForEach(LocalizationManager.supportedLanguages, id: \.code) { lang in
                        Button(action: { appLanguage = lang.code }) {
                            HStack {
                                Text("\(lang.flag) \(lang.name)")
                                if appLanguage == lang.code {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(currentLanguageDisplay)
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        Image(systemName: "chevron.down")
                            .font(AppTheme.Typography.caption2)
                            .foregroundColor(AppTheme.Colors.textTertiary)
                    }
                }
            }
        }
    }
    
    // MARK: - Premium
    
    private var premiumSection: some View {
        Section {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                HStack {
                    Text("Kombin")
                        .font(AppTheme.Typography.headline)
                    Text("PRO")
                        .font(AppTheme.Typography.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.Colors.buttonText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(AppTheme.Colors.buttonFill)
                        .clipShape(Capsule())
                }
                
                if subscriptionManager.isPremium {
                    Text("Tüm özellikler açık. Sınırsız gardırobun tadını çıkar!")
                        .font(AppTheme.Typography.caption1)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                } else {
                    Text("Sınırsız kombin • AI Koç • Valiz Modu")
                        .font(AppTheme.Typography.caption1)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    NavigationLink(destination: PremiumGateView()) {
                        Text("Yükselt")
                            .font(AppTheme.Typography.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.Colors.buttonText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.Spacing.md)
                            .background(AppTheme.Colors.buttonFill)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, AppTheme.Spacing.sm)
        }
    }
    
    // MARK: - AI Settings
    
    private var aiSettingsSection: some View {
        Section(header: Text("AI Ayarları"), footer: Text("OpenAI API anahtarınızı buradan güvenle girebilirsiniz. Anahtarınız sadece cihazınızda saklanır.")) {
            SecureField("OpenAI API Key (sk-...)", text: $apiKey)
                .font(.system(.subheadline, design: .monospaced))
        }
    }
    
    // MARK: - General
    
    private var generalSection: some View {
        Section(header: Text("General")) {
            NavigationLink(destination: Text("Notifications")) {
                Label("Notifications", systemImage: "bell")
            }
            
            NavigationLink(destination: Text("Location")) {
                Label("Weather Location", systemImage: "location")
            }
            
            NavigationLink(destination: Text("Backup")) {
                Label("iCloud Backup", systemImage: "icloud")
            }
        }
    }
    
    // MARK: - About
    
    private var aboutSection: some View {
        Section {
            NavigationLink(destination: Text("Privacy")) {
                Text("Privacy Policy")
            }
            
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }
        }
    }
    
    private var currentLanguageDisplay: String {
        let lang = LocalizationManager.supportedLanguages.first { $0.code == appLanguage }
        return "\(lang?.flag ?? "") \(lang?.name ?? "")"
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
