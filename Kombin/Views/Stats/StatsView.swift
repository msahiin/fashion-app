import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query private var items: [ClothingItem]
    @Query(sort: \CalendarEntry.date, order: .reverse) private var entries: [CalendarEntry]
    @State private var timeFilter: TimeFilter = .month
    
    enum TimeFilter: String, CaseIterable {
        case month = "Bu Ay"
        case threeMonths = "3 Ay"
        case all = "Tümü"
    }
    
    private var filteredItems: [ClothingItem] {
        guard timeFilter != .all else { return items }
        let cutoff: Date
        if timeFilter == .month {
            cutoff = Calendar.current.date(byAdding: .month, value: -1, to: .now)!
        } else {
            cutoff = Calendar.current.date(byAdding: .month, value: -3, to: .now)!
        }
        return items.filter { $0.createdAt >= cutoff }
    }
    
    private var categoryData: [(category: ClothingCategory, count: Int)] {
        var result: [(ClothingCategory, Int)] = []
        for cat in ClothingCategory.allCases {
            let count = filteredItems.filter { $0.category == cat }.count
            if count > 0 {
                result.append((cat, count))
            }
        }
        return result.sorted { $0.1 > $1.1 }
    }
    
    private var mostWorn: [ClothingItem] {
        filteredItems
            .filter { $0.wearCount > 0 }
            .sorted { $0.wearCount > $1.wearCount }
            .prefix(5)
            .map { $0 }
    }
    
    private var neverWorn: [ClothingItem] {
        filteredItems.filter { $0.wearCount == 0 }
    }
    
    private var totalValue: Double {
        filteredItems.compactMap { $0.purchasePrice }.reduce(0, +)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // Time filter
                    timeFilterPills
                    
                    // Category chart
                    categoryChartSection
                    
                    // Most worn
                    if !mostWorn.isEmpty {
                        itemsScrollSection(
                            title: "En Çok Giyilen",
                            items: mostWorn,
                            showCount: true
                        )
                    }
                    
                    // Never worn
                    if !neverWorn.isEmpty {
                        itemsScrollSection(
                            title: "Hiç Giyilmeyen 😴",
                            items: neverWorn,
                            showCount: false
                        )
                    }
                    
                    // Total value
                    if totalValue > 0 {
                        totalValueCard
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.vertical, AppTheme.Spacing.lg)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("İstatistikler")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Time Filter
    
    private var timeFilterPills: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            ForEach(TimeFilter.allCases, id: \.self) { filter in
                Button(action: { timeFilter = filter }) {
                    Text(filter.rawValue)
                        .pillStyle(isSelected: timeFilter == filter)
                }
            }
            Spacer()
        }
    }
    
    // MARK: - Category Chart
    
    private var categoryChartSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Donut chart
            ZStack {
                if #available(iOS 17, *) {
                    Chart(categoryData, id: \.category) { item in
                        SectorMark(
                            angle: .value("Count", item.count),
                            innerRadius: .ratio(0.65),
                            angularInset: 1.5
                        )
                        .foregroundStyle(colorForCategory(item.category))
                        .cornerRadius(4)
                    }
                    .frame(height: 200)
                }
                
                // Center text
                VStack(spacing: 2) {
                    Text("\(filteredItems.count)")
                        .font(AppTheme.Typography.title1)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    Text("kıyafet")
                        .font(AppTheme.Typography.caption1)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            
            // Legend
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.Spacing.sm) {
                ForEach(categoryData, id: \.category) { item in
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Circle()
                            .fill(colorForCategory(item.category))
                            .frame(width: 10, height: 10)
                        
                        Text(LocalizedStringKey(item.category.displayKey))
                            .font(AppTheme.Typography.caption1)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        Spacer()
                        
                        Text("\(item.count)")
                            .font(AppTheme.Typography.caption1)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .cardStyle()
    }
    
    // MARK: - Items Scroll
    
    private func itemsScrollSection(title: String, items: [ClothingItem], showCount: Bool) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text(title)
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.md) {
                    ForEach(items) { item in
                        VStack(spacing: AppTheme.Spacing.xs) {
                            ZStack(alignment: .topTrailing) {
                                ZStack {
                                    AppTheme.Colors.elevatedBackground
                                    if let data = item.displayImage,
                                       let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .padding(AppTheme.Spacing.sm)
                                    } else {
                                        Image(systemName: "tshirt")
                                            .foregroundColor(AppTheme.Colors.textTertiary)
                                    }
                                }
                                .frame(width: 90, height: 90)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                                        .stroke(AppTheme.Colors.border, lineWidth: 1)
                                )
                                
                                // Wear count badge
                                if showCount {
                                    Text("\(item.wearCount)x")
                                        .font(AppTheme.Typography.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(AppTheme.Colors.buttonText)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(AppTheme.Colors.buttonFill)
                                        .clipShape(Capsule())
                                        .offset(x: 4, y: -4)
                                }
                            }
                            
                            Text(item.name)
                                .font(AppTheme.Typography.caption2)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                                .lineLimit(1)
                                .frame(width: 90)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Total Value
    
    private var totalValueCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Gardırop Değeri")
                    .font(AppTheme.Typography.caption1)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                Text("₺\(String(format: "%.0f", totalValue))")
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
            Spacer()
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 28, weight: .ultraLight))
                .foregroundColor(AppTheme.Colors.textTertiary)
        }
        .padding(AppTheme.Spacing.lg)
        .cardStyle()
    }
    
    // MARK: - Helpers
    
    private func colorForCategory(_ category: ClothingCategory) -> Color {
        switch category {
        case .top: return Color(hex: "#2C2C2E")
        case .tshirt: return Color(hex: "#636366")
        case .bottom: return Color(hex: "#8E8E93")
        case .shoes: return Color(hex: "#AEAEB2")
        case .accessory: return Color(hex: "#C7C7CC")
        case .outerwear: return Color(hex: "#48484A")
        case .shorts: return Color(hex: "#D1D1D6")
        case .skirt: return Color(hex: "#3A3A3C")
        }
    }
}

#Preview {
    StatsView()
}
