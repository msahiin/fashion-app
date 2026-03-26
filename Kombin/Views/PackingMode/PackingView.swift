import SwiftUI
import SwiftData

struct PackingView: View {
    @Query(sort: \Outfit.name) private var outfits: [Outfit]
    @Query(sort: \ClothingItem.name) private var allItems: [ClothingItem]
    @Environment(\.modelContext) private var modelContext
    
    @State private var tripName: String = ""
    @State private var destination: String = ""
    @State private var startDate: Date = .now
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 5, to: .now)!
    @State private var dayOutfits: [Date: Outfit] = [:]
    @State private var showSetup = true
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showPremiumGate = false
    
    private var tripDays: [Date] {
        var days: [Date] = []
        var current = Calendar.current.startOfDay(for: startDate)
        let end = Calendar.current.startOfDay(for: endDate)
        while current <= end {
            days.append(current)
            current = Calendar.current.date(byAdding: .day, value: 1, to: current)!
        }
        return days
    }
    
    private var packingSummary: (tops: Int, bottoms: Int, shoes: Int) {
        let allOutfitItems = dayOutfits.values.flatMap { $0.items }
        let uniqueItems = Set(allOutfitItems.compactMap { $0.clothingItem?.id })
        let items = allItems.filter { uniqueItems.contains($0.id) }
        
        let tops = items.filter { $0.category.slot == .top }.count
        let bottoms = items.filter { $0.category.slot == .bottom }.count
        let shoes = items.filter { $0.category.slot == .shoes }.count
        return (tops, bottoms, shoes)
    }
    
    var body: some View {
        NavigationStack {
            if subscriptionManager.isPremium {
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        if showSetup {
                            tripSetupSection
                        } else {
                            tripInfoCard
                            dayByDaySection
                            summarySection
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.vertical, AppTheme.Spacing.lg)
                }
                .background(AppTheme.Colors.background)
                .navigationTitle("Valiz Modu ✈️")
                .navigationBarTitleDisplayMode(.large)
            } else {
                premiumLockOverlay
            }
        }
    }
    
    private var premiumLockOverlay: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "suitcase.fill")
                .font(.system(size: 64))
                .foregroundColor(.yellow)
            
            Text("Valiz Modu")
                .font(AppTheme.Typography.title1)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("Seyahatlerinize göre otomatik kapsül gardırop oluşturmak ve valizinizi akıllıca hazırlamak için PRO'ya geçin.")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)
            
            Button("PRO Özellikleri Keşfet") {
                showPremiumGate = true
            }
            .font(AppTheme.Typography.headline)
            .foregroundColor(AppTheme.Colors.buttonText)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(AppTheme.Colors.buttonFill)
            .clipShape(Capsule())
            .padding(.top, AppTheme.Spacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.background)
        .sheet(isPresented: $showPremiumGate) {
            PremiumGateView()
        }
    }
    
    // MARK: - Trip Setup
    
    private var tripSetupSection: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Text("Nereye gidiyorsun?")
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                TextField("Barcelona, Paris...", text: $destination)
                    .font(AppTheme.Typography.body)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .background(AppTheme.Colors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
                    .overlay(RoundedRectangle(cornerRadius: AppTheme.Radius.sm).stroke(AppTheme.Colors.border, lineWidth: 1))
            }
            
            HStack(spacing: AppTheme.Spacing.lg) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Text("Gidiş")
                        .font(AppTheme.Typography.caption1)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    DatePicker("", selection: $startDate, displayedComponents: .date)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Text("Dönüş")
                        .font(AppTheme.Typography.caption1)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    DatePicker("", selection: $endDate, in: startDate..., displayedComponents: .date)
                        .labelsHidden()
                }
            }
            
            Button(action: { withAnimation { showSetup = false } }) {
                Text("Planlamaya Başla")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.buttonText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.lg)
                    .background(destination.isEmpty ? AppTheme.Colors.textTertiary : AppTheme.Colors.buttonFill)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            }
            .disabled(destination.isEmpty)
        }
    }
    
    // MARK: - Trip Info Card
    
    private var tripInfoCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("İstanbul → \(destination)")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text(tripDateString)
                    .font(AppTheme.Typography.caption1)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            Text("✈️")
                .font(.system(size: 28))
            
            Button(action: { withAnimation { showSetup = true } }) {
                Image(systemName: "pencil")
                    .font(AppTheme.Typography.caption1)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
        .padding(AppTheme.Spacing.lg)
        .cardStyle()
    }
    
    // MARK: - Day by Day
    
    private var dayByDaySection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ForEach(Array(tripDays.enumerated()), id: \.offset) { index, date in
                dayRow(index: index + 1, date: date)
            }
            
            // Auto-suggest button
            Button(action: autoSuggest) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "wand.and.stars")
                    Text("Otomatik Öner")
                }
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.md)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                        .stroke(AppTheme.Colors.border, lineWidth: 1)
                )
            }
        }
    }
    
    private func dayRow(index: Int, date: Date) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            // Day header
            HStack {
                Text("Gün \(index)")
                    .font(AppTheme.Typography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text("— \(dayString(date))")
                    .font(AppTheme.Typography.caption1)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                Spacer()
                
                Text("☀️ 18°C")
                    .font(AppTheme.Typography.caption2)
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }
            
            // Outfit or placeholder
            if let outfit = dayOutfits[Calendar.current.startOfDay(for: date)] {
                HStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(outfit.items.prefix(4)) { outfitItem in
                        if let data = outfitItem.clothingItem?.displayImage,
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 44, height: 44)
                                .background(AppTheme.Colors.elevatedBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                    
                    Spacer()
                    
                    Text(outfit.name)
                        .font(AppTheme.Typography.caption1)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                .padding(AppTheme.Spacing.md)
                .cardStyle()
            } else {
                Menu {
                    ForEach(outfits) { outfit in
                        Button(outfit.name) {
                            dayOutfits[Calendar.current.startOfDay(for: date)] = outfit
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus")
                            .foregroundColor(AppTheme.Colors.textTertiary)
                        Text("Kombin seç")
                            .font(AppTheme.Typography.caption1)
                            .foregroundColor(AppTheme.Colors.textTertiary)
                        Spacer()
                    }
                    .padding(AppTheme.Spacing.lg)
                    .dashedCardStyle()
                }
            }
        }
    }
    
    // MARK: - Summary
    
    private var summarySection: some View {
        HStack(spacing: AppTheme.Spacing.xl) {
            statBadge("Üst", count: packingSummary.tops, icon: "tshirt")
            statBadge("Alt", count: packingSummary.bottoms, icon: "figure.walk")
            statBadge("Ayakkabı", count: packingSummary.shoes, icon: "shoe")
        }
        .padding(AppTheme.Spacing.lg)
        .cardStyle()
    }
    
    private func statBadge(_ label: String, count: Int, icon: String) -> some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: icon)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
            Text("\(count)")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            Text(label)
                .font(AppTheme.Typography.caption2)
                .foregroundColor(AppTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Helpers
    
    private func autoSuggest() {
        let availableOutfits = outfits.shuffled()
        for (index, date) in tripDays.enumerated() {
            let key = Calendar.current.startOfDay(for: date)
            if dayOutfits[key] == nil && index < availableOutfits.count {
                dayOutfits[key] = availableOutfits[index]
            }
        }
    }
    
    private var tripDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
    
    private func dayString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
}

#Preview {
    PackingView()
}
