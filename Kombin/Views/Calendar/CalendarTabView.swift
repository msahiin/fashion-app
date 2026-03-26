import SwiftUI
import SwiftData

struct CalendarTabView: View {
    @Query(sort: \CalendarEntry.date) private var entries: [CalendarEntry]
    @Query(sort: \Outfit.name) private var outfits: [Outfit]
    @State private var selectedDate: Date = .now
    @State private var displayedMonth: Date = .now
    @State private var showOutfitPicker = false
    
    @Environment(\.modelContext) private var modelContext
    
    private let calendar = Calendar.current
    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // Month navigation
                    monthHeader
                    
                    // Calendar grid
                    calendarGrid
                    
                    // Selected day outfit
                    selectedDaySection
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.vertical, AppTheme.Spacing.lg)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle(LocalizedStringKey("calendar_title"))
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Month Header
    
    private var monthHeader: some View {
        HStack {
            Button(action: { changeMonth(-1) }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
            
            Spacer()
            
            Text(monthYearString)
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Spacer()
            
            Button(action: { changeMonth(1) }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
        }
    }
    
    // MARK: - Calendar Grid
    
    private var calendarGrid: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            // Weekday headers
            HStack {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(AppTheme.Typography.caption1)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Date cells
            let days = daysInMonth()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: AppTheme.Spacing.sm) {
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        dayCell(date)
                    } else {
                        Text("")
                            .frame(height: 40)
                    }
                }
            }
        }
    }
    
    private func dayCell(_ date: Date) -> some View {
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let hasOutfit = entries.contains { calendar.isDate($0.date, inSameDayAs: date) }
        
        return Button(action: { selectedDate = date }) {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(
                        isSelected ? AppTheme.Colors.buttonText :
                        isToday ? AppTheme.Colors.textPrimary :
                        AppTheme.Colors.textPrimary
                    )
                    .fontWeight(isToday ? .bold : .regular)
                    .frame(width: 32, height: 32)
                    .background(isSelected ? AppTheme.Colors.buttonFill : Color.clear)
                    .clipShape(Circle())
                
                Circle()
                    .fill(hasOutfit ? AppTheme.Colors.textPrimary : Color.clear)
                    .frame(width: 4, height: 4)
            }
            .frame(height: 40)
        }
    }
    
    // MARK: - Selected Day Section
    
    private var selectedDaySection: some View {
        let entry = entries.first { calendar.isDate($0.date, inSameDayAs: selectedDate) }
        
        return VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Text(selectedDateString)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Button(action: { showOutfitPicker = true }) {
                    Text(entry != nil
                         ? LocalizedStringKey("change")
                         : LocalizedStringKey("new_outfit"))
                        .font(AppTheme.Typography.caption1)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.vertical, AppTheme.Spacing.xs)
                        .overlay(
                            Capsule().stroke(AppTheme.Colors.border, lineWidth: 1)
                        )
                }
            }
            
            if let outfit = entry?.outfit {
                // Outfit preview
                HStack(spacing: AppTheme.Spacing.md) {
                    Text(outfit.name)
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Spacer()
                    
                    // Small thumbnails
                    ForEach(outfit.items.prefix(4)) { item in
                        if let data = item.clothingItem?.displayImage,
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36, height: 36)
                                .background(AppTheme.Colors.elevatedBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }
                .padding(AppTheme.Spacing.lg)
                .cardStyle()
            } else {
                Text(LocalizedStringKey("no_outfit_planned"))
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.textTertiary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .dashedCardStyle()
            }
        }
        .sheet(isPresented: $showOutfitPicker) {
            outfitPickerSheet
        }
    }
    
    private var outfitPickerSheet: some View {
        NavigationStack {
            List(outfits) { outfit in
                Button(action: {
                    assignOutfit(outfit)
                    showOutfitPicker = false
                }) {
                    Text(outfit.name)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
            }
            .navigationTitle(LocalizedStringKey("my_outfits"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Helpers
    
    private func assignOutfit(_ outfit: Outfit) {
        // Remove existing entry for this date
        if let existing = entries.first(where: { calendar.isDate($0.date, inSameDayAs: selectedDate) }) {
            modelContext.delete(existing)
        }
        
        let entry = CalendarEntry(date: selectedDate, outfit: outfit)
        modelContext.insert(entry)
        
        // Update wear counts
        for item in outfit.items {
            item.clothingItem?.wearCount += 1
            item.clothingItem?.lastWornDate = selectedDate
        }
    }
    
    private func changeMonth(_ delta: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: delta, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }
    
    private func daysInMonth() -> [Date?] {
        let range = calendar.range(of: .day, in: .month, for: displayedMonth)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }
    
    private var selectedDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: selectedDate)
    }
}

#Preview {
    CalendarTabView()
}
