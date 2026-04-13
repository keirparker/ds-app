import SwiftUI

struct TopicBadge: View {
    let topic: Topic

    var body: some View {
        Text("\(topic.emoji) \(topic.rawValue)")
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(topic.accentColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(topic.accentColor.opacity(0.15))
            )
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 8) {
        TopicBadge(topic: .mlFundamentals)
        TopicBadge(topic: .deepLearning)
        TopicBadge(topic: .statistics)
    }
    .padding()
    .background(Color.theme.background)
}
