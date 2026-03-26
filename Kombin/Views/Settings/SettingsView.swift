import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("appTheme") private var appTheme: String = "system"
    @AppStorage("appLanguage") private var appLanguage: String = "tr"
    @AppStorage("openai_api_key") private var apiKey: String = ""
    @Query private var users: [User]
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.modelContext) private var modelContext
    
    @State private var showProfileEditor = false
    @State private var editingName = ""
    @State private var editingGender: Gender = .other
    @State private var showLanguageAlert = false
    
    private var currentUser: User? { users.first }
    
    var body: some View {
        List {
            profileSection
            appearanceSection
            premiumSection
            aiSettingsSection
            generalSection
            aboutSection
        }
        .navigationTitle("Ayarlar")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showProfileEditor) {
            profileEditorSheet
        }
    }
    
    // MARK: - Profile
    
    private var profileSection: some View {
        Section {
            Button(action: {
                editingName = currentUser?.name ?? ""
                editingGender = currentUser?.gender ?? .other
                showProfileEditor = true
            }) {
                HStack(spacing: AppTheme.Spacing.lg) {
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
                        Text("Profili Düzenle")
                            .font(AppTheme.Typography.caption1)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(AppTheme.Typography.caption1)
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
            }
        }
    }
    
    // MARK: - Profile Editor Sheet
    
    private var profileEditorSheet: some View {
        NavigationStack {
            Form {
                Section(header: Text("Profil Bilgileri")) {
                    TextField("İsim", text: $editingName)
                    
                    Picker("Cinsiyet", selection: $editingGender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(LocalizedStringKey(gender.displayKey)).tag(gender)
                        }
                    }
                }
            }
            .navigationTitle("Profili Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") { showProfileEditor = false }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        if let user = currentUser {
                            user.name = editingName
                            user.gender = editingGender
                        }
                        showProfileEditor = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Appearance
    
    private var appearanceSection: some View {
        Section(header: Text("Görünüm")) {
            Picker("Tema", selection: $appTheme) {
                Text("Açık").tag("light")
                Text("Koyu").tag("dark")
                Text("Sistem").tag("system")
            }
            .pickerStyle(.segmented)
            
            Picker("Dil", selection: $appLanguage) {
                ForEach(LocalizationManager.supportedLanguages, id: \.code) { lang in
                    Text(lang.name).tag(lang.code)
                }
            }
            .onChange(of: appLanguage) { _, newValue in
                UserDefaults.standard.set([newValue], forKey: "AppleLanguages")
                UserDefaults.standard.synchronize()
                showLanguageAlert = true
            }
        }
        .alert("Dil Değiştirildi", isPresented: $showLanguageAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text("Yeni dilin aktif olması için lütfen uygulamayı kapatıp tekrar açın.")
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
        Section(header: Text("Genel")) {
            NavigationLink(destination: Text("Bildirimler yakında aktif olacak.")) {
                Label("Bildirimler", systemImage: "bell")
            }
            
            NavigationLink(destination: Text("iCloud yedekleme yakında aktif olacak.")) {
                Label("iCloud Yedekleme", systemImage: "icloud")
            }
        }
    }
    
    // MARK: - About
    
    private var aboutSection: some View {
        Section(header: Text("Hakkında")) {
            Link(destination: URL(string: "https://example.com/privacy")!) {
                HStack {
                    Text("Gizlilik Politikası")
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(AppTheme.Typography.caption2)
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
            }
            
            Link(destination: URL(string: "https://apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                HStack {
                    Text("Kullanım Şartları")
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(AppTheme.Typography.caption2)
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
            }
            
            HStack {
                Text("Sürüm")
                Spacer()
                Text("1.2.0")
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
