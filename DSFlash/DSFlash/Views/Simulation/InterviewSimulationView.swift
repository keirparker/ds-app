import SwiftUI
import SwiftData

struct InterviewSimulationView: View {
    @Query private var allCards: [Flashcard]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Config state
    @State private var cardCount: Int = 15
    @State private var timePerCard: Int = 90
    @State private var selectedTopics: Set<Topic> = []

    // MARK: - Session state
    @State private var phase: Phase = .config
    @State private var sessionCards: [Flashcard] = []
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var timeRemaining = 0
    @State private var ticker: Timer? = nil
    @State private var ratings: [UUID: SRSRating] = [:]

    enum Phase { case config, study, results }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                switch phase {
                case .config:  configView
                case .study:   studyView
                case .results:
                    SimulationResultsView(
                        cards: sessionCards,
                        ratings: ratings,
                        timePerCard: timePerCard,
                        onRetry: { phase = .config; stopTimer() },
                        onDone:  { dismiss() }
                    )
                }
            }
            .navigationTitle("Interview Sim")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onDisappear { stopTimer() }
    }

    // MARK: - Config

    private var configView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Mock Interview")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.theme.textPrimary)
                    Text("Cards are drawn randomly. You'll be timed on each one.")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.theme.textSecondary)
                }
                .padding(.top, 8)

                configSection("Number of Cards") {
                    HStack(spacing: 10) {
                        ForEach([10, 15, 20, 30], id: \.self) { n in
                            SelectionPill(label: "\(n)", isSelected: cardCount == n) { cardCount = n }
                        }
                    }
                }

                configSection("Time Per Card") {
                    HStack(spacing: 10) {
                        ForEach([60, 90, 120, 180], id: \.self) { t in
                            SelectionPill(label: "\(t)s", isSelected: timePerCard == t) { timePerCard = t }
                        }
                    }
                }

                configSection("Filter Topics  (optional — blank = all)") {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(Topic.allCases, id: \.self) { topic in
                            TopicPicker(
                                topic: topic,
                                isSelected: selectedTopics.contains(topic)
                            ) { toggle(topic) }
                        }
                    }
                }

                Button(action: startSession) {
                    Text("Start Interview")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.theme.knownGreen))
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Study

    private var studyView: some View {
        VStack(spacing: 0) {
            timerBar

            if currentIndex < sessionCards.count {
                let card = sessionCards[currentIndex]
                VStack(spacing: 16) {
                    Spacer(minLength: 0)

                    ZStack {
                        CardFrontView(card: card)
                            .flipEffect(angle: isFlipped ? -90 : 0)
                        CardBackView(card: card)
                            .flipEffect(angle: isFlipped ? 0 : 90)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 360)
                    .padding(.horizontal, 20)
                    .onTapGesture {
                        withAnimation(.cardFlip) { isFlipped.toggle() }
                    }

                    if isFlipped {
                        ratingRow(for: card)
                            .padding(.horizontal, 20)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        Text("Tap to reveal answer")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.theme.textSecondary)
                    }

                    Spacer(minLength: 0)
                }
                .animation(.spring(response: 0.35), value: isFlipped)
            }
        }
    }

    private var timerBar: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Card \(currentIndex + 1) of \(sessionCards.count)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.theme.textSecondary)
                Spacer()
                Text("\(timeRemaining)s")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(timerColor)
            }
            .padding(.horizontal, 20)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Color.theme.separator
                    timerColor
                        .frame(
                            width: timePerCard > 0
                                ? geo.size.width * CGFloat(timeRemaining) / CGFloat(timePerCard) : 0
                        )
                        .animation(.linear(duration: 0.9), value: timeRemaining)
                }
            }
            .frame(height: 3)
        }
        .padding(.vertical, 10)
        .background(Color.theme.surface)
    }

    private var timerColor: Color {
        let f = timePerCard > 0 ? Double(timeRemaining) / Double(timePerCard) : 0
        return f > 0.5 ? Color.theme.knownGreen : f > 0.25 ? Color.theme.reviewAmber : Color(hex: "#F87171")
    }

    private func ratingRow(for card: Flashcard) -> some View {
        HStack(spacing: 10) {
            ForEach(SRSRating.allCases, id: \.rawValue) { rating in
                Button { rate(card: card, rating: rating) } label: {
                    VStack(spacing: 5) {
                        Image(systemName: rating.icon)
                            .font(.system(size: 15, weight: .semibold))
                        Text(rating.label)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(rating.color)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(rating.color.opacity(0.1))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(rating.color.opacity(0.3), lineWidth: 1))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Session logic

    private func toggle(_ topic: Topic) {
        if selectedTopics.contains(topic) { selectedTopics.remove(topic) }
        else { selectedTopics.insert(topic) }
    }

    private func startSession() {
        let pool = selectedTopics.isEmpty
            ? allCards
            : allCards.filter { selectedTopics.contains($0.topic) }
        sessionCards = Array(pool.shuffled().prefix(cardCount))
        currentIndex = 0
        ratings = [:]
        isFlipped = false
        phase = .study
        resetTimer()
    }

    private func rate(card: Flashcard, rating: SRSRating) {
        stopTimer()
        ratings[card.id] = rating
        SRSEngine.apply(rating: rating, to: card)
        StreakManager.recordCardStudied()
        try? modelContext.save()

        let next = currentIndex + 1
        if next >= sessionCards.count {
            phase = .results
        } else {
            currentIndex = next
            isFlipped = false
            resetTimer()
        }
    }

    private func resetTimer() {
        stopTimer()
        timeRemaining = timePerCard
        ticker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else if currentIndex < sessionCards.count {
                rate(card: sessionCards[currentIndex], rating: .again)
            }
        }
    }

    private func stopTimer() { ticker?.invalidate(); ticker = nil }

    // MARK: - Config helpers

    @ViewBuilder
    private func configSection<V: View>(_ title: String, @ViewBuilder content: () -> V) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.theme.textSecondary)
                .textCase(.uppercase).kerning(0.8)
            content()
        }
    }
}

// MARK: - SelectionPill

private struct SelectionPill: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(isSelected ? Color.theme.background : Color.theme.textPrimary)
                .padding(.horizontal, 20).padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.theme.knownGreen : Color.theme.surface)
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? Color.theme.knownGreen : Color.theme.separator, lineWidth: 1))
                )
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - TopicPicker

private struct TopicPicker: View {
    let topic: Topic
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(topic.emoji).font(.system(size: 14))
                Text(topic.rawValue.components(separatedBy: " & ").first ?? topic.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isSelected ? topic.accentColor : Color.theme.textSecondary)
                    .lineLimit(1)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(topic.accentColor)
                }
            }
            .padding(.horizontal, 12).padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? topic.accentColor.opacity(0.1) : Color.theme.surface)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? topic.accentColor.opacity(0.4) : Color.theme.separator, lineWidth: 1))
            )
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}
