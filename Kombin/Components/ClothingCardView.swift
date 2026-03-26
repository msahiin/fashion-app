import SwiftUI

struct ClothingCardView: View {
    let item: ClothingItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: AppTheme.Spacing.sm) {
                // Image
                ZStack {
                    AppTheme.Colors.elevatedBackground
                    
                    if let imageData = item.displayImage,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .padding(AppTheme.Spacing.sm)
                    } else {
                        Image(systemName: "tshirt")
                            .font(.system(size: 32, weight: .ultraLight))
                            .foregroundColor(AppTheme.Colors.textTertiary)
                    }
                }
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sm))
                
                // Name
                Text(item.name)
                    .font(AppTheme.Typography.caption1)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineLimit(1)
                
                // Tags
                HStack(spacing: 4) {
                    Text(LocalizedStringKey(item.style.displayKey))
                        .font(AppTheme.Typography.caption2)
                    
                    Text("•")
                        .font(AppTheme.Typography.caption2)
                    
                    if item.seasons.contains(.allSeason) {
                        Text(LocalizedStringKey("season_allSeason"))
                            .font(AppTheme.Typography.caption2)
                    } else if let firstSeason = item.seasons.first {
                        Text(LocalizedStringKey(firstSeason.displayKey))
                            .font(AppTheme.Typography.caption2)
                    }
                }
                .foregroundColor(AppTheme.Colors.textTertiary)
            }
            .padding(AppTheme.Spacing.sm)
            .background(AppTheme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(AppTheme.Colors.border, lineWidth: 1)
            )
            .overlay(alignment: .topTrailing) {
                if item.isFavorite {
                    Image(systemName: "heart.fill")
                        .font(AppTheme.Typography.caption2)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .padding(AppTheme.Spacing.sm)
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
        isFavorite: true
    )
    ClothingCardView(item: item, onTap: {})
        .frame(width: 170)
}
