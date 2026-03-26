import Foundation
import SwiftData
import SwiftUI

@Model
final class ClothingItem {
    var name: String
    var category: ClothingCategory
    var colorHex: String
    var seasons: [Season]
    var style: StylePreference
    var brand: String
    var notes: String
    var imageData: Data?
    var aiIllustrationData: Data?
    var isFavorite: Bool
    var wearCount: Int
    var lastWornDate: Date?
    var purchasePrice: Double?
    var createdAt: Date
    
    @Relationship(deleteRule: .nullify, inverse: \OutfitItem.clothingItem)
    var outfitItems: [OutfitItem]?
    
    init(
        name: String = "",
        category: ClothingCategory = .top,
        colorHex: String = "#000000",
        seasons: [Season] = [.allSeason],
        style: StylePreference = .casual,
        brand: String = "",
        notes: String = "",
        imageData: Data? = nil,
        aiIllustrationData: Data? = nil,
        isFavorite: Bool = false,
        wearCount: Int = 0,
        lastWornDate: Date? = nil,
        purchasePrice: Double? = nil,
        createdAt: Date = .now
    ) {
        self.name = name
        self.category = category
        self.colorHex = colorHex
        self.seasons = seasons
        self.style = style
        self.brand = brand
        self.notes = notes
        self.imageData = imageData
        self.aiIllustrationData = aiIllustrationData
        self.isFavorite = isFavorite
        self.wearCount = wearCount
        self.lastWornDate = lastWornDate
        self.purchasePrice = purchasePrice
        self.createdAt = createdAt
    }
    
    var color: Color {
        Color(hex: colorHex)
    }
    
    var displayImage: Data? {
        aiIllustrationData ?? imageData
    }
}

enum ClothingCategory: String, Codable, CaseIterable {
    case top = "top"
    case tshirt = "tshirt"
    case bottom = "bottom"
    case shoes = "shoes"
    case accessory = "accessory"
    case outerwear = "outerwear"
    case shorts = "shorts"
    case skirt = "skirt"
    
    var displayKey: String {
        return "category_\(rawValue)"
    }
    
    var icon: String {
        switch self {
        case .top: return "👔"
        case .tshirt: return "👕"
        case .bottom: return "👖"
        case .shoes: return "👟"
        case .accessory: return "💎"
        case .outerwear: return "🧥"
        case .shorts: return "🩳"
        case .skirt: return "👗"
        }
    }
    
    /// Mannequin slot this category belongs to
    var slot: MannequinSlot {
        switch self {
        case .top, .tshirt: return .top
        case .bottom, .shorts, .skirt: return .bottom
        case .shoes: return .shoes
        case .accessory: return .accessory
        case .outerwear: return .top
        }
    }
}

enum MannequinSlot: String, Codable, CaseIterable {
    case top = "top"
    case bottom = "bottom"
    case shoes = "shoes"
    case accessory = "accessory"
    
    var displayKey: String {
        return "slot_\(rawValue)"
    }
}

enum Season: String, Codable, CaseIterable {
    case spring = "spring"
    case summer = "summer"
    case autumn = "autumn"
    case winter = "winter"
    case allSeason = "allSeason"
    
    var displayKey: String {
        return "season_\(rawValue)"
    }
}
