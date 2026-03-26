import Foundation
import SwiftData

@Model
final class OutfitItem {
    var slot: MannequinSlot
    
    @Relationship(deleteRule: .nullify)
    var clothingItem: ClothingItem?
    
    var outfit: Outfit?
    
    init(slot: MannequinSlot, clothingItem: ClothingItem? = nil) {
        self.slot = slot
        self.clothingItem = clothingItem
    }
}
