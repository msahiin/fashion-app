import Foundation
import Combine

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "appLanguage")
        }
    }
    
    static let supportedLanguages: [(code: String, name: String, flag: String)] = [
        ("tr", "Türkçe", "🇹🇷"),
        ("en", "English", "🇬🇧"),
        ("es", "Español", "🇪🇸"),
        ("de", "Deutsch", "🇩🇪")
    ]
    
    init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage")
        let deviceLang = Locale.current.language.languageCode?.identifier ?? "en"
        let supported = Self.supportedLanguages.map { $0.code }
        
        if let saved = saved, supported.contains(saved) {
            self.currentLanguage = saved
        } else if supported.contains(deviceLang) {
            self.currentLanguage = deviceLang
        } else {
            self.currentLanguage = "en"
        }
    }
}
