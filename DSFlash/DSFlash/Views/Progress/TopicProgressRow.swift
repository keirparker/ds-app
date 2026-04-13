import SwiftUI

struct TopicProgressRow: View {
    let topic: Topic
    let cards: [Flashcard]

    private var knownCount: Int  { cards.filter(\.isKnown).count }
    private var reviewCount: Int { cards.filter { $0.needsReview && !$0.isKnown }.count }
    private var unseenCount: Int { cards.filter { !$0.isKnown && !$0.needsReview }.count }
    private var total: Int       { cards.count }

    var body: some View {
        HStack(spacing: 12) {
            // Emoji + Name
            HStack(spacing: 8) {
                Text(topic.emoji)
                    .font(.system(size: 22))
                    .frame(width: 32)

                Text(topic.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.theme.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 160, alignment: .leading)

            // Segmented progress bar
            GeometryReader { geometry in
                HStack(spacing: 2) {
                    if knownCount > 0 {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.theme.knownGreen)
                            .frame(width: barWidth(geometry.size.width, fraction: Double(knownCount) / Double(max(total, 1))))
                    }
                    if reviewCount > 0 {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.theme.reviewAmber)
                            .frame(width: barWidth(geometry.size.width, fraction: Double(reviewCount) / Double(max(total, 1))))
                    }
                    if unseenCount > 0 {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.theme.separator)
                            .frame(width: barWidth(geometry.size.width, fraction: Double(unseenCount) / Double(max(total, 1))))
                    }
                    Spacer(minLength: 0)
                }
            }
            .frame(height: 8)

            // Fraction label
            Text("\(knownCount)/\(total)")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.theme.textSecondary)
                .frame(width: 44, alignment: .trailing)
                .monospacedDigit()
        }
        .padding(.vertical, 6)
    }

    private func barWidth(_ totalWidth: CGFloat, fraction: Double) -> CGFloat {
        max(0, totalWidth * fraction - 2)
    }
}

#Preview {
    VStack(spacing: 0) {
        TopicProgressRow(topic: .mlFundamentals, cards: [])
        TopicProgressRow(topic: .statistics, cards: [])
    }
    .padding()
    .background(Color.theme.background)
}
