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

                        FormattedTextView(
                            text: card.answer,
                            fontSize: 17,
                            fontWeight: .semibold
                        )
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

                        FormattedTextView(
                            text: card.explanation,
                            fontSize: 15,
                            fontWeight: .regular,
                            textColor: Color.theme.textSecondary
                        )
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
