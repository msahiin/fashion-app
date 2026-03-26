import SwiftUI
import SwiftData

struct WardrobeView: View {
    @Query(sort: \ClothingItem.createdAt, order: .reverse) private var allItems: [ClothingItem]
    @State private var selectedCategory: ClothingCategory? = nil
    @State private var showAddItem = false
    @State private var searchText = ""
    
    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.Spacing.md),
        GridItem(.flexible(), spacing: AppTheme.Spacing.md)
    ]
    
    private var filteredItems: [ClothingItem] {
        var items = allItems
        
        if let category = selectedCategory {
            items = items.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            items = items.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.brand.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return items
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category tabs
                categoryTabs
                
                // Grid or empty state
                if filteredItems.isEmpty {
                    emptyState
                } else {
                    itemsGrid
                }
            }
            .background(AppTheme.Colors.background)
            .navigationTitle(LocalizedStringKey("wardrobe_title"))
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: LocalizedStringKey("search"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddItem = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                }
            }
            .sheet(isPresented: $showAddItem) {
                AddItemView()
            }
        }
    }
    
    // MARK: - Category Tabs
    
    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                // All
                Button(action: { selectedCategory = nil }) {
                    Text(LocalizedStringKey("category_all"))
                        .pillStyle(isSelected: selectedCategory == nil)
                }
                
                ForEach(ClothingCategory.allCases, id: \.self) { category in
                    Button(action: { selectedCategory = category }) {
                        Text(LocalizedStringKey(category.displayKey))
                            .pillStyle(isSelected: selectedCategory == category)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.xl)
            .padding(.vertical, AppTheme.Spacing.md)
        }
    }
    
    // MARK: - Items Grid
    
    private var itemsGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: AppTheme.Spacing.md) {
                ForEach(filteredItems) { item in
                    NavigationLink(destination: ClothingDetailView(item: item)) {
                        ClothingCardView(item: item, onTap: {})
                            .allowsHitTesting(false)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.xl)
            .padding(.bottom, AppTheme.Spacing.xl)
            
            // Item count
            Text(String(format: NSLocalizedString("items_count", comment: ""), filteredItems.count))
                .font(AppTheme.Typography.caption1)
                .foregroundColor(AppTheme.Colors.textTertiary)
                .padding(.bottom, AppTheme.Spacing.xxl)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()
            
            Image(systemName: "tshirt")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundColor(AppTheme.Colors.textTertiary)
            
            Text(LocalizedStringKey("empty_wardrobe"))
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: { showAddItem = true }) {
                Text(LocalizedStringKey("add_item_title"))
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.buttonText)
                    .padding(.horizontal, AppTheme.Spacing.xxl)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(AppTheme.Colors.buttonFill)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            }
            
            Spacer()
        }
    }
}

#Preview {
    WardrobeView()
}
