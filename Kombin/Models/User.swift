import Foundation
import SwiftData

@Model
final class User {
    var name: String
    var gender: Gender
    var selectedStyles: [StylePreference]
    var createdAt: Date
    
    init(
        name: String = "",
        gender: Gender = .other,
        selectedStyles: [StylePreference] = [],
        createdAt: Date = .now
    ) {
        self.name = name
        self.gender = gender
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
        case .classic: return "briefcase"
        case .casual: return "tshirt"
        case .sporty: return "figure.run"
        case .elegant: return "sparkles"
        case .bohemian: return "leaf"
        case .minimalist: return "square"
        case .streetwear: return "cap.fill" // Or custom
        case .vintage: return "clock"
        }
    }
}
