import Foundation
import SwiftData

@Model
final class CalendarEntry {
    var date: Date
    var outfit: Outfit?
    var weatherTemp: Double?
    var weatherCondition: String?
    var notes: String
    
    init(
        date: Date = .now,
        outfit: Outfit? = nil,
        weatherTemp: Double? = nil,
        weatherCondition: String? = nil,
        notes: String = ""
    ) {
        self.date = date
        self.outfit = outfit
        self.weatherTemp = weatherTemp
        self.weatherCondition = weatherCondition
        self.notes = notes
    }
    
    var dateOnly: Date {
        Calendar.current.startOfDay(for: date)
    }
}

@Model
final class OOTDEntry {
    var date: Date
    var selfieImageData: Data?
    var outfitName: String
    var note: String
    var mood: String
    var clothingItemIDs: [String]
    
    init(
        date: Date = .now,
        selfieImageData: Data? = nil,
        outfitName: String = "",
        note: String = "",
        mood: String = "😊",
        clothingItemIDs: [String] = []
    ) {
        self.date = date
        self.selfieImageData = selfieImageData
        self.outfitName = outfitName
        self.note = note
        self.mood = mood
        self.clothingItemIDs = clothingItemIDs
    }
}
