import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var users: [User]
    @Query(sort: \CalendarEntry.date, order: .reverse) private var calendarEntries: [CalendarEntry]
    @Query private var outfits: [Outfit]
    
    @StateObject private var locationManager = LocationManager()
    
    private var currentUser: User? { users.first }
    
    private var greeting: LocalizedStringKey {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "greeting_morning"
        case 12..<18: return "greeting_afternoon"
        default: return "greeting_evening"
        }
    }
    
    private var todayEntry: CalendarEntry? {
        let today = Calendar.current.startOfDay(for: .now)
        return calendarEntries.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }
    
    private var weekDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            return []
        }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xl) {
                    // Header
                    headerSection
                    
                    // Today's Outfit
                    todayOutfitSection
                    
                    // Weekly Strip
                    weeklyStripSection
                    
                    // Quick Actions
                    quickActionsSection
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.top, AppTheme.Spacing.md)
            }
            .background(AppTheme.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                }
            }
            .onAppear {
                locationManager.requestLocation()
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                Text(currentUser?.name ?? "")
                    .font(AppTheme.Typography.title1)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
            
            Spacer()
            
            // Weather badge
            if !locationManager.currentCity.isEmpty {
                HStack(spacing: 4) {
                    Text("\(locationManager.currentCity), \(locationManager.temperature)°C")
                        .font(AppTheme.Typography.caption1)
                    Image(systemName: locationManager.weatherIcon)
                        .font(AppTheme.Typography.caption1)
                }
                .foregroundColor(AppTheme.Colors.textSecondary)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.xs)
                .overlay(
                    Capsule()
                        .stroke(AppTheme.Colors.border, lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - Today's Outfit
    
    private var todayOutfitSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text(LocalizedStringKey("todays_outfit"))
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            if let outfit = todayEntry?.outfit {
                outfitPreviewCard(outfit)
            } else {
                emptyOutfitCard
            }
        }
    }
    
    private func outfitPreviewCard(_ outfit: Outfit) -> some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ForEach(MannequinSlot.allCases, id: \.self) { slot in
                if let item = outfit.item(for: slot),
                   let imageData = item.displayImage {
                    Image(uiImage: UIImage(data: imageData) ?? UIImage())
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.Colors.elevatedBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .cardStyle()
    }
    
    private var emptyOutfitCard: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "tshirt")
                .font(.system(size: 40, weight: .ultraLight))
                .foregroundColor(AppTheme.Colors.textTertiary)
            
            Text(LocalizedStringKey("no_outfit_planned"))
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .dashedCardStyle()
    }
    
    // MARK: - Weekly Strip
    
    private var weeklyStripSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text(LocalizedStringKey("weekly_plan"))
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(weekDays, id: \.self) { date in
                        WeekDayCard(
                            date: date,
                            isToday: Calendar.current.isDateInToday(date),
                            hasOutfit: calendarEntries.contains {
                                Calendar.current.isDate($0.date, inSameDayAs: date)
                            }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.md) {
                NavigationLink(destination: OutfitCreatorView()) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "plus.square")
                            .font(AppTheme.Typography.body)
                        Text(LocalizedStringKey("new_outfit"))
                            .font(AppTheme.Typography.subheadline)
                    }
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.lg)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                            .stroke(AppTheme.Colors.border, lineWidth: 1)
                    )
                }
                
                NavigationLink(destination: WardrobeView()) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "tshirt")
                            .font(AppTheme.Typography.body)
                        Text(LocalizedStringKey("wardrobe_title"))
                            .font(AppTheme.Typography.subheadline)
                    }
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.lg)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                            .stroke(AppTheme.Colors.border, lineWidth: 1)
                    )
                }
            }
            
            // Feature grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.Spacing.md) {
                featureLink(
                    title: "İstatistikler",
                    icon: "chart.pie",
                    destination: AnyView(StatsView())
                )
                featureLink(
                    title: "Valiz Modu",
                    icon: "suitcase",
                    destination: AnyView(PackingView())
                )
                featureLink(
                    title: "AI Stil Koçu",
                    icon: "sparkles",
                    destination: AnyView(AIStyleCoachView()),
                    isPro: true
                )
                featureLink(
                    title: "OOTD Günlüğü",
                    icon: "camera.viewfinder",
                    destination: AnyView(OOTDDiaryView())
                )
            }
        }
        .padding(.bottom, AppTheme.Spacing.xl)
    }
    
    private func featureLink(title: String, icon: String, destination: AnyView, isPro: Bool = false) -> some View {
        NavigationLink(destination: destination) {
            VStack(spacing: AppTheme.Spacing.sm) {
                HStack {
                    Spacer()
                    if isPro {
                        Text("PRO")
                            .font(AppTheme.Typography.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.Colors.buttonText)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppTheme.Colors.buttonFill)
                            .clipShape(Capsule())
                    }
                }
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .light))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text(title)
                    .font(AppTheme.Typography.caption1)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.lg)
            .padding(.horizontal, AppTheme.Spacing.sm)
            .cardStyle()
        }
    }
}

// MARK: - Week Day Card

struct WeekDayCard: View {
    let date: Date
    let isToday: Bool
    let hasOutfit: Bool
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Text(dayName)
                .font(AppTheme.Typography.caption2)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Text(dayNumber)
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(isToday ? AppTheme.Colors.buttonText : AppTheme.Colors.textPrimary)
                .frame(width: 32, height: 32)
                .background(isToday ? AppTheme.Colors.buttonFill : Color.clear)
                .clipShape(Circle())
            
            Circle()
                .fill(hasOutfit ? AppTheme.Colors.textPrimary : Color.clear)
                .frame(width: 5, height: 5)
        }
        .frame(width: 48)
    }
}

#Preview {
    DashboardView()
}
