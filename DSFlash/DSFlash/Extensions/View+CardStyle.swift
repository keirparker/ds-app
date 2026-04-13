import SwiftUI

extension View {
    func cardStyle(accentColor: Color) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.theme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(accentColor.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.4), radius: 16, x: 0, y: 8)
            )
    }

    func sectionHeader() -> some View {
        self
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(Color.theme.textSecondary)
            .textCase(.uppercase)
            .kerning(1.2)
    }
}
