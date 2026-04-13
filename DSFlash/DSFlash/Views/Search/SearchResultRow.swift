import SwiftUI

struct SearchResultRow: View {
    let card: Flashcard

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Left: question + topic badge
            VStack(alignment: .leading, spacing: 8) {
                Text(card.question)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.theme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                TopicBadge(topic: card.topic)
            }

            Spacer()

            // Right: difficulty badge
            DifficultyBadge(difficulty: card.difficulty)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.theme.surface)
        )
        .contentShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    VStack(spacing: 8) {
        SearchResultRow(card: Flashcard(
            topicRaw: Topic.mlFundamentals.rawValue,
            difficultyRaw: Difficulty.intermediate.rawValue,
            question: "What is the bias-variance tradeoff in machine learning?",
            answer: "A fundamental tension between a model's ability to fit training data and generalise.",
            explanation: "High bias leads to underfitting; high variance leads to overfitting."
        ))
    }
    .padding()
    .background(Color.theme.background)
}
