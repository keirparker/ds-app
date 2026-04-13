import SwiftUI

struct CardFrontView: View {
    let card: Flashcard

    var body: some View {
        HStack(spacing: 0) {
            // Left accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(card.topic.accentColor)
                .frame(width: 4)
                .padding(.vertical, 28)

            VStack(alignment: .leading, spacing: 0) {
                // Topic + Difficulty badges
                HStack(spacing: 8) {
                    TopicBadge(topic: card.topic)
                    DifficultyBadge(difficulty: card.difficulty)
                    Spacer()
                }
                .padding(.bottom, 24)

                Spacer()

                // Question
                Text(card.question)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity)

                Spacer()

                // Tap hint
                HStack {
                    Spacer()
                    Text("Tap to reveal answer")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.theme.textSecondary)
                    Spacer()
                }
                .padding(.top, 24)
            }
            .padding(28)
        }
    }
}
