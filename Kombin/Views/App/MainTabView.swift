import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    
    enum Tab: Hashable {
        case home
        case wardrobe
        case create
        case calendar
        case outfits
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label {
                        Text(LocalizedStringKey("tab_home"))
                    } icon: {
                        Image(systemName: selectedTab == .home ? "house.fill" : "house")
                    }
                }
                .tag(Tab.home)
            
            WardrobeView()
                .tabItem {
                    Label {
                        Text(LocalizedStringKey("tab_wardrobe"))
                    } icon: {
                        Image(systemName: "tshirt")
                    }
                }
                .tag(Tab.wardrobe)
            
            OutfitCreatorView()
                .tabItem {
                    Label {
                        Text(LocalizedStringKey("tab_create"))
                    } icon: {
                        Image(systemName: "plus.square")
                    }
                }
                .tag(Tab.create)
            
            CalendarTabView()
                .tabItem {
                    Label {
                        Text(LocalizedStringKey("tab_calendar"))
                    } icon: {
                        Image(systemName: "calendar")
                    }
                }
                .tag(Tab.calendar)
            
            SavedOutfitsView()
                .tabItem {
                    Label {
                        Text(LocalizedStringKey("tab_outfits"))
                    } icon: {
                        Image(systemName: selectedTab == .outfits ? "heart.fill" : "heart")
                    }
                }
                .tag(Tab.outfits)
        }
        .tint(AppTheme.Colors.tabActive)
    }
}

#Preview {
    MainTabView()
}
