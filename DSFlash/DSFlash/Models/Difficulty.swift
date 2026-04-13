import SwiftUI

enum Difficulty: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case senior = "Senior"
    case lead = "Team Lead"

    var color: Color {
        switch self {
        case .beginner:     return Color.theme.knownGreen
        case .intermediate: return Color.theme.blue
        case .senior:       return Color.theme.violet
        case .lead:         return Color.theme.gold
        }
    }

    var shortLabel: String {
        switch self {
        case .beginner:     return "Beginner"
        case .intermediate: return "Mid"
        case .senior:       return "Senior"
        case .lead:         return "Lead"
        }
    }
}
