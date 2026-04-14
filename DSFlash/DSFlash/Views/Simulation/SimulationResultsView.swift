import SwiftUI

struct SimulationResultsView: View {
    let cards: [Flashcard]
    let ratings: [UUID: SRSRating]
    let timePerCard: Int
    let onRetry: () -> Void
    let onDone: () -> Void

    private var rated: [(card: Flashcard, rating: SRSRating)] {
        cards.compactMap { c in ratings[c.id].map { (c, $0) } }
    }

    private var passed: Int { rated.filter { $0.rating.rawValue >= 2 }.count }
    private var pct: Int    { cards.isEmpty ? 0 : Int(Double(passed) / Double(cards.count) * 100) }

    private var byTopic: [(topic: Topic, good: Int, total: Int)] {
        Dictionary(grouping: rated) { $0.card.topic }
            .map { topic, pairs in
                (topic, pairs.filter { $0.rating.rawValue >= 2 }.count, pairs.count)
            }
            .sorted { $0.total > $1.total }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 8)

                // Score ring
                ZStack {
                    Circle().stroke(Color.theme.separator, lineWidth: 10)
                        .frame(width: 130, height: 130)
                    Circle()
                        .trim(from: 0, to: CGFloat(pct) / 100)
                        .stroke(ringColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 130, height: 130)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 0.8), value: pct)
                    VStack(spacing: 2) {
                        Text("\(pct)%")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(ringColor)
                        Text("\(passed)/\(cards.count)")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.theme.textSecondary)
                    }
                }

                Text(verdict)
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(Color.theme.textPrimary)

                // Rating distribution
                HStack(spacing: 10) {
                    ForEach(SRSRating.allCases, id: \.rawValue) { r in
                        let count = rated.filter { $0.rating == r }.count
                        VStack(spacing: 4) {
                            Text("\(count)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(r.color)
                            Text(r.label)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Color.theme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(r.color.opacity(0.08))
                                .overlay(RoundedRectangle(cornerRadius: 12)
                                    .stroke(r.color.opacity(0.2), lineWidth: 1))
                        )
                    }
                }

                // Topic breakdown
                if !byTopic.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("By Topic")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.theme.textSecondary)
                            .textCase(.uppercase).kerning(0.8)

                        ForEach(byTopic, id: \.topic) { item in
                            TopicRow(topic: item.topic, good: item.good, total: item.total)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                VStack(spacing: 12) {
                    Button(action: onRetry) {
                        Text("New Simulation")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.theme.background)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(RoundedRectangle(cornerRadius: 16).fill(ringColor))
                    }
                    Button(action: onDone) {
                        Text("Done")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(Color.theme.textSecondary)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.theme.surface))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }

    private var ringColor: Color {
        pct >= 80 ? Color.theme.knownGreen : pct >= 60 ? Color.theme.reviewAmber : Color(hex: "#F87171")
    }
    private var verdict: String {
        pct >= 80 ? "Interview Ready ✓" : pct >= 60 ? "Getting There" : "More Practice Needed"
    }
}

// MARK: - TopicRow

private struct TopicRow: View {
    let topic: Topic
    let good: Int
    let total: Int
    private var pct: Double { total > 0 ? Double(good) / Double(total) : 0 }

    var body: some View {
        HStack(spacing: 12) {
            Text(topic.emoji).font(.system(size: 18))

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(topic.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.theme.textPrimary)
                    Spacer()
                    Text("\(good)/\(total)")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.theme.textSecondary)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.theme.separator).frame(height: 5)
                        Capsule()
                            .fill(topic.accentColor)
                            .frame(width: geo.size.width * pct, height: 5)
                            .animation(.easeOut(duration: 0.6), value: pct)
                    }
                }
                .frame(height: 5)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.theme.surface))
    }
}
