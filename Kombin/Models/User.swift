import Foundation
import SwiftData

@Model
final class User {
    var name: String
    var gender: Gender
    var birthYear: Int
    var profileImageData: Data?
    var selectedStyles: [StylePreference]
    var createdAt: Date
    
    init(
        name: String = "",
        gender: Gender = .other,
        birthYear: Int = 2000,
        profileImageData: Data? = nil,
        selectedStyles: [StylePreference] = [],
        createdAt: Date = .now
    ) {
        self.name = name
        self.gender = gender
        self.birthYear = birthYear
        self.profileImageData = profileImageData
        self.selectedStyles = selectedStyles
        self.createdAt = createdAt
    }
}

enum Gender: String, Codable, CaseIterable {
    case male = "male"
    case female = "female"
    case other = "other"
    
    var displayKey: String {
        switch self {
        case .male: return "gender_male"
        case .female: return "gender_female"
        case .other: return "gender_other"
        }
    }
}

enum StylePreference: String, Codable, CaseIterable {
    case classic = "classic"
    case casual = "casual"
    case sporty = "sporty"
    case elegant = "elegant"
    case bohemian = "bohemian"
    case minimalist = "minimalist"
    case streetwear = "streetwear"
    case vintage = "vintage"
    
    var displayKey: String {
        return "style_\(rawValue)"
    }
    
    var icon: String {
        switch self {
        case .classic: return "👔"
        case .casual: return "👕"
        case .sporty: return "🏃"
        case .elegant: return "✨"
        case .bohemian: return "🌸"
        case .minimalist: return "◻️"
        case .streetwear: return "🧢"
        case .vintage: return "🕰️"
        }
    }
}
