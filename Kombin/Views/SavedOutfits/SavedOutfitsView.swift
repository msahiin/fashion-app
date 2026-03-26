import SwiftUI
import SwiftData

struct SavedOutfitsView: View {
    @Query(sort: \Outfit.createdAt, order: .reverse) private var outfits: [Outfit]
    @State private var selectedFilter: String = "all"
    @State private var searchText: String = ""
    
    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.Spacing.md),
        GridItem(.flexible(), spacing: AppTheme.Spacing.md)
    ]
    
    private var filteredOutfits: [Outfit] {
        var result = outfits
        
        if selectedFilter == "favorites" {
            result = result.filter { $0.isFavorite }
        } else if selectedFilter != "all" {
            result = result.filter { $0.tags.contains(selectedFilter) }
        }
        
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return result
    }
    
    private var allTags: [String] {
        let tags = outfits.flatMap { $0.tags }
        return Array(Set(tags)).sorted()
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter pills
                filterBar
                
                // Grid
                if filteredOutfits.isEmpty {
                    emptyState
                } else {
                    outfitGrid
                }
            }
            .background(AppTheme.Colors.background)
            .navigationTitle(LocalizedStringKey("my_outfits"))
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: LocalizedStringKey("search"))
        }
    }
    
    // MARK: - Filter Bar
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Button(action: { selectedFilter = "all" }) {
                    Text(LocalizedStringKey("category_all"))
                        .pillStyle(isSelected: selectedFilter == "all")
                }
                
                Button(action: { selectedFilter = "favorites" }) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(AppTheme.Typography.caption2)
                        Text("Favorites")
                    }
                    .pillStyle(isSelected: selectedFilter == "favorites")
                }
                
                ForEach(allTags, id: \.self) { tag in
                    Button(action: { selectedFilter = tag }) {
                        Text(tag)
                            .pillStyle(isSelected: selectedFilter == tag)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.xl)
            .padding(.vertical, AppTheme.Spacing.md)
        }
    }
    
    // MARK: - Grid
    
    private var outfitGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: AppTheme.Spacing.md) {
                ForEach(filteredOutfits) { outfit in
                    OutfitCardView(outfit: outfit)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.xl)
            .padding(.bottom, AppTheme.Spacing.xl)
            
            Text(String(format: NSLocalizedString("outfits_count", comment: ""), filteredOutfits.count))
                .font(AppTheme.Typography.caption1)
                .foregroundColor(AppTheme.Colors.textTertiary)
                .padding(.bottom, AppTheme.Spacing.xxl)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()
            Image(systemName: "heart")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundColor(AppTheme.Colors.textTertiary)
            Text("No outfits yet")
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.textSecondary)
            Spacer()
        }
    }
}

// MARK: - Outfit Card

struct OutfitCardView: View {
    let outfit: Outfit
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            // 2x2 mini collage
            let items = outfit.items.prefix(4)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, outfitItem in
                    if let data = outfitItem.clothingItem?.displayImage,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(AppTheme.Colors.elevatedBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    } else {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppTheme.Colors.elevatedBackground)
                            .frame(height: 55)
                    }
                }
            }
            
            // Name + favorite
            HStack {
                Text(outfit.name)
                    .font(AppTheme.Typography.caption1)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineLimit(1)
                
                Spacer()
                
                Button(action: { outfit.isFavorite.toggle() }) {
                    Image(systemName: outfit.isFavorite ? "heart.fill" : "heart")
                        .font(AppTheme.Typography.caption2)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
            }
            
            // Tags
            if !outfit.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(outfit.tags.prefix(2), id: \.self) { tag in
                        Text(tag)
                            .font(AppTheme.Typography.caption2)
                            .foregroundColor(AppTheme.Colors.textTertiary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .overlay(
                                Capsule().stroke(AppTheme.Colors.border, lineWidth: 0.5)
                            )
                    }
                    Spacer()
                }
            }
        }
        .padding(AppTheme.Spacing.sm)
        .cardStyle()
    }
}

#Preview {
    SavedOutfitsView()
}
