import SwiftUI
import SwiftData

@main
struct KombinApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("appTheme") private var appTheme: String = "system"
    @AppStorage("appLanguage") private var appLanguage: String = "tr"
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            ClothingItem.self,
            Outfit.self,
            OutfitItem.self,
            CalendarEntry.self,
            OOTDEntry.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(colorScheme)
        }
        .modelContainer(sharedModelContainer)
    }
    
    private var colorScheme: ColorScheme? {
        switch appTheme {
        case "dark": return .dark
        case "light": return .light
        default: return nil // system
        }
    }
}
