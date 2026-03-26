import SwiftUI
import SwiftData
import PhotosUI

struct ClothingDetailView: View {
    @Bindable var item: ClothingItem
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var isEditing: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isRemovingBG: Bool = false
    @State private var bgRemovalError: String?
    
    // Edit state
    @State private var editName: String = ""
    @State private var editCategory: ClothingCategory = .top
    @State private var editColorHex: String = "#000000"
    @State private var editSeasons: [Season] = []
    @State private var editStyle: StylePreference = .casual
    @State private var editBrand: String = ""
    @State private var editNotes: String = ""
    
    private let presetColors: [(name: String, hex: String)] = [
        ("Black", "#000000"), ("White", "#FFFFFF"),
        ("Navy", "#1B2A4A"), ("Gray", "#808080"),
        ("Brown", "#8B4513"), ("Red", "#C41E3A"),
        ("Green", "#2D5A27"), ("Blue", "#2563EB"),
        ("Beige", "#C8AD7F"), ("Pink", "#E91E8C")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.xl) {
                // Image section
                imageSection
                
                if isEditing {
                    editFormSection
                } else {
                    detailSection
                }
            }
            .padding(.horizontal, AppTheme.Spacing.xl)
            .padding(.vertical, AppTheme.Spacing.lg)
        }
        .background(AppTheme.Colors.background)
        .navigationTitle(isEditing ? LocalizedStringKey("edit") : LocalizedStringKey(item.name))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditing {
                    Button(LocalizedStringKey("save")) { saveEdits() }
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .fontWeight(.semibold)
                } else {
                    Menu {
                        Button(action: { startEditing() }) {
                            Label(String(localized: "edit"), systemImage: "pencil")
                        }
                        
                        Button(action: { toggleFavorite() }) {
                            Label(
                                item.isFavorite ? "Unfavorite" : "Favorite",
                                systemImage: item.isFavorite ? "heart.slash" : "heart"
                            )
                        }
                        
                        Divider()
                        
                        Button(role: .destructive, action: { showDeleteConfirmation = true }) {
                            Label(String(localized: "delete"), systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                }
            }
            
            if isEditing {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStringKey("cancel")) { isEditing = false }
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
        }
        .alert("Bu kıyafeti silmek istediğinden emin misin?", isPresented: $showDeleteConfirmation) {
            Button(LocalizedStringKey("delete"), role: .destructive) { deleteItem() }
            Button(LocalizedStringKey("cancel"), role: .cancel) { }
        } message: {
            Text("Bu işlem geri alınamaz. Kıyafet tüm kombinlerden kaldırılacak.")
        }
    }
    
    // MARK: - Image Section
    
    private var imageSection: some View {
        ZStack {
            if let imageData = item.displayImage,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 320)
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.Colors.elevatedBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                            .stroke(AppTheme.Colors.border, lineWidth: 1)
                    )
                    .overlay(alignment: .bottomTrailing) {
                        if isEditing {
                            imageActionButtons
                        }
                    }
            } else {
                VStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: "tshirt")
                        .font(.system(size: 64, weight: .ultraLight))
                        .foregroundColor(AppTheme.Colors.textTertiary)
                    
                    if isEditing {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Text("Fotoğraf Ekle")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(AppTheme.Colors.textPrimary)
                                .padding(.horizontal, AppTheme.Spacing.lg)
                                .padding(.vertical, AppTheme.Spacing.sm)
                                .overlay(Capsule().stroke(AppTheme.Colors.border, lineWidth: 1))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .background(AppTheme.Colors.elevatedBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
            }
            
            // Loading overlay for BG removal
            if isRemovingBG {
                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                    .fill(Color.black.opacity(0.4))
                    .frame(maxWidth: .infinity)
                    .frame(height: 320)
                    .overlay(
                        VStack(spacing: AppTheme.Spacing.sm) {
                            ProgressView()
                                .tint(.white)
                            Text("Arkaplan kaldırılıyor...")
                                .font(AppTheme.Typography.caption1)
                                .foregroundColor(.white)
                        }
                    )
            }
        }
        .onChange(of: selectedPhotoItem) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    item.imageData = data
                }
            }
        }
    }
    
    private var imageActionButtons: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            // Remove BG
            Button(action: { removeBackground() }) {
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
            }
            
            // Change photo
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(AppTheme.Typography.caption1)
                    .foregroundColor(AppTheme.Colors.buttonText)
                    .padding(AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.buttonFill)
                    .clipShape(Circle())
            }
        }
        .padding(AppTheme.Spacing.md)
    }
    
    // MARK: - Detail Section (Read-only)
    
    private var detailSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Stats row
            HStack(spacing: AppTheme.Spacing.xl) {
                statItem(value: "\(item.wearCount)", label: "Giyim")
                
                if let lastWorn = item.lastWornDate {
                    statItem(value: daysSince(lastWorn), label: "Son Giyim")
                }
                
                if let price = item.purchasePrice {
                    statItem(value: "₺\(Int(price))", label: "Fiyat")
                }
                
                Spacer()
            }
            .padding(AppTheme.Spacing.lg)
            .cardStyle()
            
            // Info cards
            infoRow(icon: "tag", label: "Kategori", value: LocalizedStringKey(item.category.displayKey))
            infoRow(icon: "paintpalette", label: "Renk", colorHex: item.colorHex)
            infoRow(icon: "leaf", label: "Mevsim", value: seasonsText)
            infoRow(icon: "sparkles", label: "Tarz", value: LocalizedStringKey(item.style.displayKey))
            
            if !item.brand.isEmpty {
                infoRow(icon: "building.2", label: "Marka", text: item.brand)
            }
            
            if !item.notes.isEmpty {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "note.text")
                            .font(AppTheme.Typography.caption1)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        Text("Not")
                            .font(AppTheme.Typography.caption1)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    Text(item.notes)
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(AppTheme.Spacing.lg)
                .cardStyle()
            }
            
            // Error display
            if let error = bgRemovalError {
                Text(error)
                    .font(AppTheme.Typography.caption1)
                    .foregroundColor(Color("Error"))
                    .padding(AppTheme.Spacing.md)
                    .frame(maxWidth: .infinity)
                    .background(Color("Error").opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
            }
        }
    }
    
    // MARK: - Edit Form
    
    private var editFormSection: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            // Name
            formField(label: "İsim", text: $editName)
            
            // Category
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Text("Kategori")
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        ForEach(ClothingCategory.allCases, id: \.self) { cat in
                            Button(action: { editCategory = cat }) {
                                HStack(spacing: 4) {
                                    Text(cat.icon).font(AppTheme.Typography.caption1)
                                    Text(LocalizedStringKey(cat.displayKey))
                                }
                                .pillStyle(isSelected: editCategory == cat)
                            }
                        }
                    }
                }
            }
            
            // Color
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Text(LocalizedStringKey("color_label"))
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Spacing.md) {
                        ForEach(presetColors, id: \.hex) { c in
                            Button(action: { editColorHex = c.hex }) {
                                Circle()
                                    .fill(Color(hex: c.hex))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                editColorHex == c.hex ? AppTheme.Colors.textPrimary : AppTheme.Colors.border,
                                                lineWidth: editColorHex == c.hex ? 2 : 1
                                            )
                                            .padding(editColorHex == c.hex ? -3 : 0)
                                    )
                            }
                        }
                    }
                }
            }
            
            // Season
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Text(LocalizedStringKey("season_label"))
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        ForEach(Season.allCases, id: \.self) { season in
                            Button(action: { toggleSeason(season) }) {
                                Text(LocalizedStringKey(season.displayKey))
                                    .pillStyle(isSelected: editSeasons.contains(season))
                            }
                        }
                    }
                }
            }
            
            // Style
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Text(LocalizedStringKey("style_label"))
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        ForEach(StylePreference.allCases, id: \.self) { style in
                            Button(action: { editStyle = style }) {
                                Text(LocalizedStringKey(style.displayKey))
                                    .pillStyle(isSelected: editStyle == style)
                            }
                        }
                    }
                }
            }
            
            // Brand
            formField(label: "Marka", text: $editBrand)
            
            // Notes
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Text(LocalizedStringKey("notes_label"))
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                TextEditor(text: $editNotes)
                    .font(AppTheme.Typography.body)
                    .frame(minHeight: 80)
                    .padding(AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                            .stroke(AppTheme.Colors.border, lineWidth: 1)
                    )
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            Text(label)
                .font(AppTheme.Typography.caption2)
                .foregroundColor(AppTheme.Colors.textTertiary)
        }
    }
    
    private func infoRow(icon: String, label: String, value: LocalizedStringKey) -> some View {
        HStack {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(AppTheme.Typography.caption1)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .frame(width: 20)
                Text(label)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            Spacer()
            Text(value)
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
        .padding(AppTheme.Spacing.lg)
        .cardStyle()
    }
    
    private func infoRow(icon: String, label: String, text: String) -> some View {
        HStack {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(AppTheme.Typography.caption1)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .frame(width: 20)
                Text(label)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            Spacer()
            Text(text)
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
        .padding(AppTheme.Spacing.lg)
        .cardStyle()
    }
    
    private func infoRow(icon: String, label: String, colorHex: String) -> some View {
        HStack {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(AppTheme.Typography.caption1)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .frame(width: 20)
                Text(label)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            Spacer()
            Circle()
                .fill(Color(hex: colorHex))
                .frame(width: 24, height: 24)
                .overlay(Circle().stroke(AppTheme.Colors.border, lineWidth: 1))
        }
        .padding(AppTheme.Spacing.lg)
        .cardStyle()
    }
    
    private func formField(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(label)
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.textSecondary)
            TextField("", text: text)
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
    
    // MARK: - Computed
    
    private var seasonsText: LocalizedStringKey {
        if item.seasons.contains(.allSeason) {
            return "season_allSeason"
        }
        let keys = item.seasons.map { $0.displayKey }
        return LocalizedStringKey(keys.joined(separator: ", "))
    }
    
    private func daysSince(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: date, to: .now).day ?? 0
        if days == 0 { return "Bugün" }
        if days == 1 { return "Dün" }
        return "\(days) gün"
    }
    
    // MARK: - Actions
    
    private func startEditing() {
        editName = item.name
        editCategory = item.category
        editColorHex = item.colorHex
        editSeasons = item.seasons
        editStyle = item.style
        editBrand = item.brand
        editNotes = item.notes
        isEditing = true
    }
    
    private func saveEdits() {
        item.name = editName
        item.category = editCategory
        item.colorHex = editColorHex
        item.seasons = editSeasons
        item.style = editStyle
        item.brand = editBrand
        item.notes = editNotes
        isEditing = false
    }
    
    private func toggleFavorite() {
        item.isFavorite.toggle()
    }
    
    private func deleteItem() {
        modelContext.delete(item)
        dismiss()
    }
    
    private func toggleSeason(_ season: Season) {
        if season == .allSeason {
            editSeasons = [.allSeason]
        } else {
            editSeasons.removeAll { $0 == .allSeason }
            if editSeasons.contains(season) {
                editSeasons.removeAll { $0 == season }
            } else {
                editSeasons.append(season)
            }
            if editSeasons.isEmpty { editSeasons = [.allSeason] }
        }
    }
    
    private func removeBackground() {
        guard let imageData = item.imageData else { return }
        isRemovingBG = true
        bgRemovalError = nil
        
        Task {
            do {
                let result = try await BackgroundRemovalService.shared.removeBackground(from: imageData, quality: .free)
                await MainActor.run {
                    item.imageData = result
                    isRemovingBG = false
                }
            } catch {
                await MainActor.run {
                    bgRemovalError = error.localizedDescription
                    isRemovingBG = false
                }
            }
        }
    }
}

#Preview {
    let item = ClothingItem(
        name: "Beyaz Gömlek",
        category: .top,
        colorHex: "#FFFFFF",
        seasons: [.allSeason],
        style: .classic,
        brand: "Zara",
        isFavorite: true,
        wearCount: 12
    )
    NavigationStack {
        ClothingDetailView(item: item)
    }
}
