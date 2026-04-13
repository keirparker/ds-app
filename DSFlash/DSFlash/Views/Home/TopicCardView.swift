import SwiftUI

struct TopicCardView: View {
    let topic: Topic
    let cards: [Flashcard]
    let onTap: () -> Void

    private var knownCount: Int  { cards.filter(\.isKnown).count }
    private var totalCount: Int  { cards.count }
    private var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(knownCount) / Double(totalCount)
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Gradient background
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            topic.accentColor.opacity(0.15),
                            topic.accentColor.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(topic.accentColor.opacity(0.2), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 0) {
                // Topic emoji top-left
                Text(topic.emoji)
                    .font(.system(size: 40))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                HStack(alignment: .bottom) {
                    // Name + card count
                    VStack(alignment: .leading, spacing: 4) {
                        Text(topic.rawValue)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.theme.textPrimary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("\(totalCount) cards")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(Color.theme.textSecondary)
                    }

                    Spacer()

                    // Circular progress bottom-right
                    CircularProgressView(
                        progress: progress,
                        color: topic.accentColor,
                        size: 44,
                        lineWidth: 4
                    )
                }
            }
            .padding(16)
        }
        .frame(height: 160)
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
        TopicCardView(topic: .mlFundamentals, cards: [], onTap: {})
        TopicCardView(topic: .deepLearning, cards: [], onTap: {})
        TopicCardView(topic: .statistics, cards: [], onTap: {})
        TopicCardView(topic: .nlpTransformers, cards: [], onTap: {})
    }
    .padding()
    .background(Color.theme.background)
}
