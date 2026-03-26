import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query private var items: [ClothingItem]
    @Query(sort: \CalendarEntry.date, order: .reverse) private var entries: [CalendarEntry]
    @State private var timeFilter: TimeFilter = .month
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showPremiumGate = false
    
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
    
    private var wardrobeUtilization: Double {
        guard !filteredItems.isEmpty else { return 0 }
        let wornCount = filteredItems.filter { $0.wearCount > 0 }.count
        return Double(wornCount) / Double(filteredItems.count) * 100
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
                    
                    // Wardrobe Utilization (Premium)
                    wardrobeUtilizationCard
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.vertical, AppTheme.Spacing.lg)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("İstatistikler")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showPremiumGate) {
                PremiumGateView()
            }
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
    
    // MARK: - Wardrobe Utilization
    
    private var wardrobeUtilizationCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Dolap Kullanım Oranı")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            if subscriptionManager.isPremium {
                HStack(spacing: AppTheme.Spacing.xl) {
                    // Circular progress
                    ZStack {
                        Circle()
                            .stroke(AppTheme.Colors.border, lineWidth: 8)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(wardrobeUtilization) / 100)
                            .stroke(Color.yellow, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(Int(wardrobeUtilization))%")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                    .frame(width: 80, height: 80)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(wardrobeUtilization > 50 ? "Harika Gidiyorsun!" : "Daha Fazla Çeşit Deneyebilirsin")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        Text("Kıyafetlerinizin %\(Int(wardrobeUtilization))'ini en az bir kez giydiniz.")
                            .font(AppTheme.Typography.caption1)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    
                    Spacer()
                }
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.elevatedBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            } else {
                // Premium Lock
                Button(action: { showPremiumGate = true }) {
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.yellow)
                        VStack(alignment: .leading) {
                            Text("Gelişmiş Analizler Kilitli")
                                .font(AppTheme.Typography.subheadline)
                            Text("Dolap kullanım oranını görmek için PRO'ya geçin.")
                                .font(AppTheme.Typography.caption2)
                        }
                        Spacer()
                    }
                    .padding(AppTheme.Spacing.md)
                    .background(AppTheme.Colors.elevatedBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                }
                .foregroundColor(AppTheme.Colors.textPrimary)
            }
        }
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
