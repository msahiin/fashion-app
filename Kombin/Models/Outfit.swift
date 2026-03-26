import Foundation
import SwiftData

@Model
final class Outfit {
    var name: String
    var tags: [String]
    var isFavorite: Bool
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade)
    var items: [OutfitItem]
    
    @Relationship(deleteRule: .nullify, inverse: \CalendarEntry.outfit)
    var calendarEntries: [CalendarEntry]?
    
    init(
        name: String = "",
        tags: [String] = [],
        isFavorite: Bool = false,
        items: [OutfitItem] = [],
        createdAt: Date = .now
    ) {
        self.name = name
        self.tags = tags
        self.isFavorite = isFavorite
        self.items = items
        self.createdAt = createdAt
    }
    
    /// Get the clothing item for a specific mannequin slot
    func item(for slot: MannequinSlot) -> ClothingItem? {
        items.first(where: { $0.slot == slot })?.clothingItem
    }
    
    /// Total wear count across all calendar entries
    var totalWears: Int {
        calendarEntries?.count ?? 0
    }
}
