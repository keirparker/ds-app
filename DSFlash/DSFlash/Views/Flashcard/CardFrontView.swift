import SwiftUI

struct CardFrontView: View {
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

            // Question
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Question")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.theme.textSecondary)
                        .textCase(.uppercase)
                        .kerning(1.2)

                    Text(card.question)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.theme.textPrimary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
            }

            Spacer(minLength: 0)

            // Tap hint
            HStack {
                Spacer()
                Label("Tap to reveal", systemImage: "hand.tap")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.theme.textSecondary)
                Spacer()
            }
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(card.topic.accentColor.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.4), radius: 16, x: 0, y: 8)
    }
}
