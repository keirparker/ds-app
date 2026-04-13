import SwiftUI

struct CardBackView: View {
    let card: Flashcard

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                TopicBadge(topic: card.topic)
                Spacer()
                DifficultyBadge(difficulty: card.difficulty)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 20)

            Divider()
                .background(Color.theme.separator)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Answer
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Answer")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.theme.textSecondary)
                            .textCase(.uppercase)
                            .kerning(1.2)

                        Text(card.answer)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.theme.textPrimary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Divider()
                        .background(Color.theme.separator)

                    // Explanation
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Explanation")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.theme.textSecondary)
                            .textCase(.uppercase)
                            .kerning(1.2)

                        Text(card.explanation)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color.theme.textPrimary)
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(card.topic.accentColor.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.4), radius: 16, x: 0, y: 8)
    }
}
