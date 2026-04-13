import SwiftUI

struct DifficultyBadge: View {
    let difficulty: Difficulty

    var body: some View {
        Text(difficulty.shortLabel)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(difficulty.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(difficulty.color.opacity(0.2))
            )
    }
}

#Preview {
    HStack(spacing: 8) {
        DifficultyBadge(difficulty: .beginner)
        DifficultyBadge(difficulty: .intermediate)
        DifficultyBadge(difficulty: .senior)
        DifficultyBadge(difficulty: .lead)
    }
    .padding()
    .background(Color.theme.background)
}
