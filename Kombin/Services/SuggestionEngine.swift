import Foundation
import SwiftData

/// Outfit suggestion engine that recommends combinations from the user's wardrobe
class SuggestionEngine {
    
    /// Suggests an outfit based on occasion, season, and weather
    static func suggestOutfit(
        items: [ClothingItem],
        existingOutfits: [Outfit],
        occasion: Occasion = .casual,
        season: Season = .allSeason,
        temperature: Double? = nil,
        excludeRecentlyWorn: Bool = true
    ) -> SuggestedOutfit? {
        
        // Filter items by season
        var pool = items.filter { item in
            item.seasons.contains(season) || item.seasons.contains(.allSeason)
        }
        
        // Exclude recently worn (last 3 days)
        if excludeRecentlyWorn {
            let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: .now)!
            pool = pool.filter { item in
                guard let lastWorn = item.lastWornDate else { return true }
                return lastWorn < threeDaysAgo
            }
        }
        
        // Get items by slot
        let tops = pool.filter { $0.category.slot == .top }
        let bottoms = pool.filter { $0.category.slot == .bottom }
        let shoes = pool.filter { $0.category.slot == .shoes }
        let accessories = pool.filter { $0.category.slot == .accessory }
        
        guard let selectedTop = selectBestItem(from: tops, for: occasion),
              let selectedBottom = selectBestItem(from: bottoms, for: occasion) else {
            return nil
        }
        
        let selectedShoe = selectBestItem(from: shoes, for: occasion)
        let selectedAccessory = selectBestItem(from: accessories, for: occasion)
        
        let score = calculateHarmonyScore(
            top: selectedTop,
            bottom: selectedBottom,
            shoes: selectedShoe,
            accessory: selectedAccessory
        )
        
        return SuggestedOutfit(
            top: selectedTop,
            bottom: selectedBottom,
            shoes: selectedShoe,
            accessory: selectedAccessory,
            harmonyScore: score,
            reason: generateReason(occasion: occasion, score: score)
        )
    }
    
    // MARK: - Item Selection
    
    private static func selectBestItem(
        from items: [ClothingItem],
        for occasion: Occasion
    ) -> ClothingItem? {
        guard !items.isEmpty else { return nil }
        
        // Score each item based on occasion suitability
        let scored = items.map { item -> (ClothingItem, Double) in
            var score = 0.0
            
            // Style match
            switch occasion {
            case .work, .meeting:
                if [.classic, .elegant, .minimalist].contains(item.style) { score += 3 }
            case .casual, .weekend:
                if [.casual, .streetwear, .sporty].contains(item.style) { score += 3 }
            case .dinner, .date:
                if [.elegant, .classic, .bohemian].contains(item.style) { score += 3 }
            case .sport:
                if item.style == .sporty { score += 5 }
            }
            
            // Freshness bonus (not recently worn)
            if item.wearCount == 0 {
                score += 2 // Try new items
            } else if let lastWorn = item.lastWornDate {
                let daysSince = Calendar.current.dateComponents([.day], from: lastWorn, to: .now).day ?? 0
                score += min(Double(daysSince) * 0.3, 2.0)
            }
            
            // Favorite penalty (wear evenly)
            if item.isFavorite { score += 0.5 }
            
            // Add some randomness
            score += Double.random(in: 0...1.5)
            
            return (item, score)
        }
        
        return scored.sorted { $0.1 > $1.1 }.first?.0
    }
    
    // MARK: - Harmony Score
    
    private static func calculateHarmonyScore(
        top: ClothingItem,
        bottom: ClothingItem,
        shoes: ClothingItem?,
        accessory: ClothingItem?
    ) -> Double {
        var score = 50.0 // Base score
        
        // Style consistency
        if top.style == bottom.style { score += 20 }
        if let shoes = shoes, shoes.style == top.style { score += 10 }
        
        // Color harmony
        let topColor = colorComponents(top.colorHex)
        let bottomColor = colorComponents(bottom.colorHex)
        
        // Neutral colors always match
        let neutrals = ["#000000", "#FFFFFF", "#808080", "#C8AD7F"]
        if neutrals.contains(top.colorHex.uppercased()) || neutrals.contains(bottom.colorHex.uppercased()) {
            score += 15
        }
        
        // Complementary colors bonus (simplified)
        let hueDiff = abs(topColor.hue - bottomColor.hue)
        if hueDiff > 0.4 && hueDiff < 0.6 { score += 10 } // Complementary
        if hueDiff < 0.1 || hueDiff > 0.9 { score += 5 } // Monochrome
        
        return min(score, 100)
    }
    
    private static func colorComponents(_ hex: String) -> (hue: Double, sat: Double, bright: Double) {
        // Simplified hue extraction from hex
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        
        let maxC = max(r, g, b)
        let minC = min(r, g, b)
        let delta = maxC - minC
        
        var hue = 0.0
        if delta > 0 {
            if maxC == r { hue = ((g - b) / delta).truncatingRemainder(dividingBy: 6) / 6 }
            else if maxC == g { hue = ((b - r) / delta + 2) / 6 }
            else { hue = ((r - g) / delta + 4) / 6 }
        }
        if hue < 0 { hue += 1 }
        
        let sat = maxC == 0 ? 0 : delta / maxC
        
        return (hue, sat, maxC)
    }
    
    // MARK: - Reason Generation
    
    private static func generateReason(occasion: Occasion, score: Double) -> String {
        let quality: String
        if score >= 80 { quality = "Mükemmel bir uyum!" }
        else if score >= 60 { quality = "Güzel bir kombinasyon." }
        else { quality = "Farklı bir seçim." }
        
        switch occasion {
        case .work: return "İş için profesyonel bir görünüm. \(quality)"
        case .meeting: return "Toplantı için uygun, şık bir seçim. \(quality)"
        case .casual: return "Günlük için rahat ve şık. \(quality)"
        case .dinner: return "Akşam yemeği için zarif bir tercih. \(quality)"
        case .date: return "Randevu için etkileyici. \(quality)"
        case .weekend: return "Hafta sonu için ideal. \(quality)"
        case .sport: return "Spor için konforlu. \(quality)"
        }
    }
}

// MARK: - Types

enum Occasion: String, CaseIterable {
    case casual = "casual"
    case work = "work"
    case meeting = "meeting"
    case dinner = "dinner"
    case date = "date"
    case weekend = "weekend"
    case sport = "sport"
    
    var icon: String {
        switch self {
        case .casual: return "sun.max"
        case .work: return "briefcase"
        case .meeting: return "person.2"
        case .dinner: return "fork.knife"
        case .date: return "heart"
        case .weekend: return "party.popper"
        case .sport: return "figure.run"
        }
    }
    
    var displayName: String {
        switch self {
        case .casual: return "Günlük"
        case .work: return "İş"
        case .meeting: return "Toplantı"
        case .dinner: return "Yemek"
        case .date: return "Randevu"
        case .weekend: return "Hafta Sonu"
        case .sport: return "Spor"
        }
    }
}

struct SuggestedOutfit {
    let top: ClothingItem
    let bottom: ClothingItem
    let shoes: ClothingItem?
    let accessory: ClothingItem?
    let harmonyScore: Double
    let reason: String
}
