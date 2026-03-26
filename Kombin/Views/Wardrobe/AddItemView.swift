import SwiftUI
import SwiftData
import PhotosUI

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name: String = ""
    @State private var selectedCategory: ClothingCategory = .top
    @State private var selectedColorHex: String = "#000000"
    @State private var selectedSeasons: [Season] = [.allSeason]
    @State private var selectedStyle: StylePreference = .casual
    @State private var brand: String = ""
    @State private var notes: String = ""
    @State private var imageData: Data?
    @State private var isRemovingBG: Bool = false
    
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    private let presetColors: [(name: String, hex: String)] = [
        ("Black", "#000000"),
        ("White", "#FFFFFF"),
        ("Navy", "#1B2A4A"),
        ("Gray", "#808080"),
        ("Brown", "#8B4513"),
        ("Red", "#C41E3A"),
        ("Green", "#2D5A27"),
        ("Blue", "#2563EB"),
        ("Beige", "#C8AD7F"),
        ("Pink", "#E91E8C")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // Image section
                    imageSection
                    
                    // Category
                    categorySection
                    
                    // Color
                    colorSection
                    
                    // Season
                    seasonSection
                    
                    // Style
                    styleSection
                    
                    // Brand
                    formField(
                        label: "brand_label",
                        text: $brand,
                        placeholder: "Zara, H&M..."
                    )
                    
                    // Notes
                    formField(
                        label: "notes_label",
                        text: $notes,
                        placeholder: ""
                    )
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.vertical, AppTheme.Spacing.lg)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle(LocalizedStringKey("add_item_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStringKey("cancel")) { dismiss() }
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey("save")) { saveItem() }
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .fontWeight(.semibold)
                        .disabled(name.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Image Section
    
    private var imageSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            if let imageData, let uiImage = UIImage(data: imageData) {
                ZStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.Colors.elevatedBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                .stroke(AppTheme.Colors.border, lineWidth: 1)
                        )
                        .overlay(alignment: .bottomTrailing) {
                            Button(action: { removeBG() }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "scissors")
                                        .font(AppTheme.Typography.caption2)
                                    Text("BG Kaldır")
                                        .font(AppTheme.Typography.caption2)
                                }
                                .foregroundColor(AppTheme.Colors.buttonText)
                                .padding(.horizontal, AppTheme.Spacing.md)
                                .padding(.vertical, AppTheme.Spacing.xs)
                                .background(AppTheme.Colors.buttonFill)
                                .clipShape(Capsule())
                                .padding(AppTheme.Spacing.sm)
                            }
                        }
                    
                    if isRemovingBG {
                        RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                            .fill(Color.black.opacity(0.4))
                            .overlay(
                                VStack(spacing: 4) {
                                    ProgressView().tint(.white)
                                    Text("İşleniyor...").font(AppTheme.Typography.caption2).foregroundColor(.white)
                                }
                            )
                    }
                }
            } else {
                HStack(spacing: AppTheme.Spacing.lg) {
                    Button(action: { showCamera = true }) {
                        VStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: "camera")
                                .font(.system(size: 24, weight: .light))
                            Text(LocalizedStringKey("take_photo"))
                                .font(AppTheme.Typography.caption1)
                        }
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .dashedCardStyle()
                    }
                    
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        VStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: "photo")
                                .font(.system(size: 24, weight: .light))
                            Text(LocalizedStringKey("from_gallery"))
                                .font(AppTheme.Typography.caption1)
                        }
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .dashedCardStyle()
                    }
                }
            }
            
            // Name input
            TextField(LocalizedStringKey("outfit_name_placeholder"), text: $name)
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
        }
        .onChange(of: selectedPhotoItem) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    imageData = data
                }
            }
        }
    }
    
    // MARK: - Category Section
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(LocalizedStringKey("category_all"))
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(ClothingCategory.allCases, id: \.self) { category in
                        Button(action: { selectedCategory = category }) {
                            HStack(spacing: 4) {
                                Text(category.icon)
                                    .font(AppTheme.Typography.caption1)
                                Text(LocalizedStringKey(category.displayKey))
                            }
                            .pillStyle(isSelected: selectedCategory == category)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Color Section
    
    private var colorSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(LocalizedStringKey("color_label"))
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.md) {
                    ForEach(presetColors, id: \.hex) { colorInfo in
                        Button(action: { selectedColorHex = colorInfo.hex }) {
                            Circle()
                                .fill(Color(hex: colorInfo.hex))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            selectedColorHex == colorInfo.hex
                                            ? AppTheme.Colors.textPrimary
                                            : AppTheme.Colors.border,
                                            lineWidth: selectedColorHex == colorInfo.hex ? 2 : 1
                                        )
                                        .padding(selectedColorHex == colorInfo.hex ? -3 : 0)
                                )
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Season Section
    
    private var seasonSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(LocalizedStringKey("season_label"))
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(Season.allCases, id: \.self) { season in
                        Button(action: { toggleSeason(season) }) {
                            Text(LocalizedStringKey(season.displayKey))
                                .pillStyle(isSelected: selectedSeasons.contains(season))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Style Section
    
    private var styleSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(LocalizedStringKey("style_label"))
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(StylePreference.allCases, id: \.self) { style in
                        Button(action: { selectedStyle = style }) {
                            Text(LocalizedStringKey(style.displayKey))
                                .pillStyle(isSelected: selectedStyle == style)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func formField(label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(LocalizedStringKey(label))
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            TextField(placeholder, text: text)
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
        }
    }
    // MARK: - BG Removal
    
    private func removeBG() {
        guard let data = imageData else { return }
        isRemovingBG = true
        Task {
            do {
                let result = try await BackgroundRemovalService.shared.removeBackground(from: data, quality: .free)
                await MainActor.run {
                    imageData = result
                    isRemovingBG = false
                    
                    // Auto color extraction
                    if let uiImage = UIImage(data: result),
                       let closestHex = uiImage.closestPresetHexColor(from: presetColors) {
                        // Add a small animation to highlight the color change
                        withAnimation {
                            selectedColorHex = closestHex
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    isRemovingBG = false
                }
            }
        }
    }
    
    private func toggleSeason(_ season: Season) {
        if season == .allSeason {
            selectedSeasons = [.allSeason]
        } else {
            selectedSeasons.removeAll { $0 == .allSeason }
            if selectedSeasons.contains(season) {
                selectedSeasons.removeAll { $0 == season }
            } else {
                selectedSeasons.append(season)
            }
            if selectedSeasons.isEmpty {
                selectedSeasons = [.allSeason]
            }
        }
    }
    
    private func saveItem() {
        let item = ClothingItem(
            name: name,
            category: selectedCategory,
            colorHex: selectedColorHex,
            seasons: selectedSeasons,
            style: selectedStyle,
            brand: brand,
            notes: notes,
            imageData: imageData
        )
        modelContext.insert(item)
        dismiss()
    }
}

#Preview {
    AddItemView()
}
