import SwiftUI
import SwiftData

struct OutfitCreatorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ClothingItem.createdAt, order: .reverse) private var allItems: [ClothingItem]
    
    @State private var outfitName: String = ""
    @State private var tags: [String] = []
    @State private var newTag: String = ""
    @State private var selectedItems: [MannequinSlot: ClothingItem] = [:]
    @State private var activeSlot: MannequinSlot? = nil
    @State private var showItemPicker = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // Mannequin / Slots
                    slotsSection
                    
                    // Outfit name
                    TextField(LocalizedStringKey("outfit_name_placeholder"), text: $outfitName)
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .background(AppTheme.Colors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                                .stroke(AppTheme.Colors.border, lineWidth: 1)
                        )
                    
                    // Tags
                    tagsSection
                    
                    // Save button
                    Button(action: saveOutfit) {
                        Text(LocalizedStringKey("save_outfit"))
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.buttonText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.Spacing.lg)
                            .background(canSave
                                        ? AppTheme.Colors.buttonFill
                                        : AppTheme.Colors.textTertiary)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                    }
                    .disabled(!canSave)
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.vertical, AppTheme.Spacing.lg)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle(LocalizedStringKey("new_outfit"))
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showItemPicker) {
                if let slot = activeSlot {
                    ItemPickerSheet(
                        slot: slot,
                        allItems: allItems,
                        onSelect: { item in
                            selectedItems[slot] = item
                            showItemPicker = false
                        }
                    )
                }
            }
        }
    }
    
    private var canSave: Bool {
        !outfitName.isEmpty && !selectedItems.isEmpty
    }
    
    // MARK: - Slots Section
    
    private var slotsSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ForEach(MannequinSlot.allCases, id: \.self) { slot in
                slotRow(slot)
            }
        }
    }
    
    private func slotRow(_ slot: MannequinSlot) -> some View {
        Button(action: {
            activeSlot = slot
            showItemPicker = true
        }) {
            HStack(spacing: AppTheme.Spacing.lg) {
                // Slot label
                Text(LocalizedStringKey(slot.displayKey))
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .frame(width: 70, alignment: .leading)
                
                // Item preview or placeholder
                if let item = selectedItems[slot] {
                    HStack(spacing: AppTheme.Spacing.md) {
                        if let data = item.displayImage,
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .background(AppTheme.Colors.elevatedBackground)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
                        }
                        
                        Text(item.name)
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .font(AppTheme.Typography.body)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(AppTheme.Spacing.md)
                    .cardStyle()
                } else {
                    HStack {
                        Image(systemName: "plus")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.textTertiary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 70)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .dashedCardStyle()
                }
            }
        }
    }
    
    // MARK: - Tags
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(tags, id: \.self) { tag in
                        HStack(spacing: 4) {
                            Text(tag)
                                .font(AppTheme.Typography.caption1)
                            Button(action: { tags.removeAll { $0 == tag } }) {
                                Image(systemName: "xmark")
                                    .font(AppTheme.Typography.caption2)
                            }
                        }
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.vertical, AppTheme.Spacing.xs)
                        .background(AppTheme.Colors.cardBackground)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(AppTheme.Colors.border, lineWidth: 1))
                    }
                    
                    // Add tag input
                    HStack(spacing: 4) {
                        TextField("Tag...", text: $newTag)
                            .font(AppTheme.Typography.caption1)
                            .frame(width: 60)
                            .onSubmit {
                                if !newTag.isEmpty {
                                    tags.append(newTag)
                                    newTag = ""
                                }
                            }
                        Image(systemName: "plus.circle")
                            .font(AppTheme.Typography.caption1)
                            .foregroundColor(AppTheme.Colors.textTertiary)
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.xs)
                    .overlay(Capsule().stroke(AppTheme.Colors.border, lineWidth: 1))
                }
            }
        }
    }
    
    // MARK: - Save
    
    private func saveOutfit() {
        let outfit = Outfit(name: outfitName, tags: tags)
        
        for (slot, item) in selectedItems {
            let outfitItem = OutfitItem(slot: slot, clothingItem: item)
            outfit.items.append(outfitItem)
        }
        
        modelContext.insert(outfit)
        dismiss()
    }
}

// MARK: - Item Picker Sheet

struct ItemPickerSheet: View {
    let slot: MannequinSlot
    let allItems: [ClothingItem]
    let onSelect: (ClothingItem) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    private var filteredItems: [ClothingItem] {
        allItems.filter { $0.category.slot == slot }
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.Spacing.md),
        GridItem(.flexible(), spacing: AppTheme.Spacing.md),
        GridItem(.flexible(), spacing: AppTheme.Spacing.md)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: AppTheme.Spacing.md) {
                    ForEach(filteredItems) { item in
                        Button(action: { onSelect(item) }) {
                            VStack(spacing: AppTheme.Spacing.xs) {
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
                                .frame(height: 90)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                                        .stroke(AppTheme.Colors.border, lineWidth: 1)
                                )
                                
                                Text(item.name)
                                    .font(AppTheme.Typography.caption2)
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .padding(AppTheme.Spacing.xl)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle(LocalizedStringKey(slot.displayKey))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey("cancel")) { dismiss() }
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
        }
    }
}

#Preview {
    OutfitCreatorView()
}
