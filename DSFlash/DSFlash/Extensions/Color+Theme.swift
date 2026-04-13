import SwiftUI

extension Color {
    static let theme = ColorTheme()

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ColorTheme {
    let background     = Color(hex: "#0F0F14")
    let surface        = Color(hex: "#1C1C26")
    let surfaceElevated = Color(hex: "#252532")
    let textPrimary    = Color(hex: "#F0F0F5")
    let textSecondary  = Color(hex: "#8A8A9F")
    let separator      = Color(hex: "#2A2A3A")
    let knownGreen     = Color(hex: "#34D399")
    let reviewAmber    = Color(hex: "#F97316")
    let blue           = Color(hex: "#60A5FA")
    let violet         = Color(hex: "#A78BFA")
    let gold           = Color(hex: "#FBBF24")
}
