import SwiftUI
import SwiftData
import PhotosUI

struct OOTDDiaryView: View {
    @Query(sort: \OOTDEntry.date, order: .reverse) private var entries: [OOTDEntry]
    @Environment(\.modelContext) private var modelContext
    @State private var showNewEntry = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if entries.isEmpty {
                    emptyState
                } else {
                    // Instagram-style grid
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(entries) { entry in
                            OOTDGridCell(entry: entry)
                        }
                    }
                    .padding(.bottom, AppTheme.Spacing.xxl)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.Colors.background)
            .navigationTitle("OOTD Günlüğü")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showNewEntry = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                }
            }
            .sheet(isPresented: $showNewEntry) {
                NewOOTDEntryView()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundColor(AppTheme.Colors.textTertiary)
            Text("Henüz OOTD yok!\nBugünkü stilini kaydet.")
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: { showNewEntry = true }) {
                Text("Bugünün OOTD'si")
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

// MARK: - Grid Cell

struct OOTDGridCell: View {
    let entry: OOTDEntry
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let data = entry.selfieImageData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(minHeight: 130)
                    .clipped()
            } else {
                Rectangle()
                    .fill(AppTheme.Colors.elevatedBackground)
                    .frame(minHeight: 130)
                    .overlay(
                        Text(entry.mood)
                            .font(.system(size: 28))
                    )
            }
            
            // Date overlay
            VStack(alignment: .leading, spacing: 0) {
                Text(entry.mood)
                    .font(AppTheme.Typography.caption2)
                Text(shortDate(entry.date))
                    .font(AppTheme.Typography.caption2)
                    .foregroundColor(.white)
            }
            .padding(4)
            .background(Color.black.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .padding(4)
        }
        .clipShape(Rectangle())
    }
    
    private func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
}

// MARK: - New Entry

struct NewOOTDEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var note: String = ""
    @State private var selectedMood: String = "😊"
    @State private var outfitName: String = ""
    @State private var imageData: Data?
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    private let moods = ["😊", "😍", "😎", "🤩", "💪", "🥰", "✨", "🔥"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // Photo
                    photoSection
                    
                    // Mood
                    moodSection
                    
                    // Outfit name
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        Text("Kombin Adı")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        
                        TextField("Bugünkü kombinin...", text: $outfitName)
                            .font(AppTheme.Typography.body)
                            .padding(.vertical, AppTheme.Spacing.md)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .background(AppTheme.Colors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
                            .overlay(RoundedRectangle(cornerRadius: AppTheme.Radius.sm).stroke(AppTheme.Colors.border, lineWidth: 1))
                    }
                    
                    // Note
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        Text("Not")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        
                        TextEditor(text: $note)
                            .font(AppTheme.Typography.body)
                            .frame(minHeight: 80)
                            .padding(AppTheme.Spacing.sm)
                            .background(AppTheme.Colors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
                            .overlay(RoundedRectangle(cornerRadius: AppTheme.Radius.sm).stroke(AppTheme.Colors.border, lineWidth: 1))
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.vertical, AppTheme.Spacing.lg)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("Bugünün OOTD'si")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStringKey("cancel")) { dismiss() }
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey("save")) { saveEntry() }
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Photo Section
    
    private var photoSection: some View {
        Group {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            } else {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 40, weight: .ultraLight))
                            .foregroundColor(AppTheme.Colors.textTertiary)
                        Text("Selfie çek veya foto seç")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .dashedCardStyle()
                }
            }
        }
        .onChange(of: selectedPhotoItem) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    imageData = data
                }
            }
        }
    }
    
    // MARK: - Mood
    
    private var moodSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Ruh hali")
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            HStack(spacing: AppTheme.Spacing.md) {
                ForEach(moods, id: \.self) { mood in
                    Button(action: { selectedMood = mood }) {
                        Text(mood)
                            .font(.system(size: selectedMood == mood ? 32 : 24))
                            .opacity(selectedMood == mood ? 1.0 : 0.5)
                    }
                }
            }
        }
    }
    
    // MARK: - Save
    
    private func saveEntry() {
        let entry = OOTDEntry(
            selfieImageData: imageData,
            outfitName: outfitName,
            note: note,
            mood: selectedMood
        )
        modelContext.insert(entry)
        dismiss()
    }
}

#Preview {
    OOTDDiaryView()
}
