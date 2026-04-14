import SwiftUI
import SwiftData

// MARK: - QuizView

struct QuizView: View {
    let topic: Topic?

    @Query private var allCards: [Flashcard]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var sessionCards: [Flashcard] = []
    @State private var currentIndex = 0
    @State private var options: [String] = []
    @State private var correctIndex = 0
    @State private var selectedOption: Int? = nil
    @State private var score = 0
    @State private var missedCards: [Flashcard] = []
    @State private var phase: Phase = .loading

    enum Phase { case loading, question, results }

    private var current: Flashcard? {
        phase == .question && currentIndex < sessionCards.count
            ? sessionCards[currentIndex] : nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                switch phase {
                case .loading:  Color.theme.background  // brief flash before onAppear
                case .question: questionView
                case .results:  QuizResultView(
                    total: sessionCards.count,
                    score: score,
                    missedCards: missedCards,
                    onRetry: restart,
                    onDone:  { dismiss() }
                )
                }
            }
            .navigationTitle(topic.map { "\($0.emoji) Quiz" } ?? "Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if phase == .question {
                    ToolbarItem(placement: .principal) {
                        Text("\(currentIndex + 1) / \(sessionCards.count)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.theme.textSecondary)
                    }
                }
            }
        }
        .onAppear(perform: setup)
    }

    // MARK: - Question screen

    private var questionView: some View {
        VStack(spacing: 0) {
            progressBar

            if let card = current {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Badges + question
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                TopicBadge(topic: card.topic)
                                DifficultyBadge(difficulty: card.difficulty)
                                Spacer()
                            }
                            FormattedTextView(
                                text: card.question,
                                fontSize: 19,
                                fontWeight: .semibold
                            )
                        }
                        .padding(.top, 24)

                        // Answer options
                        VStack(spacing: 10) {
                            ForEach(Array(options.enumerated()), id: \.offset) { i, opt in
                                OptionButton(
                                    text: opt,
                                    index: i,
                                    selectedIndex: selectedOption,
                                    correctIndex: correctIndex
                                ) { choose(i, card: card) }
                            }
                        }

                        // Next / results button
                        if selectedOption != nil {
                            Button(action: advance) {
                                Text(currentIndex + 1 < sessionCards.count ? "Next →" : "See Results")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(Color.theme.background)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.theme.knownGreen)
                                    )
                            }
                            .padding(.top, 6)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .animation(.spring(response: 0.3), value: selectedOption)
            }
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Color.theme.separator
                Color.theme.knownGreen
                    .frame(
                        width: geo.size.width * (sessionCards.isEmpty ? 0
                            : CGFloat(currentIndex) / CGFloat(sessionCards.count))
                    )
                    .animation(.easeInOut(duration: 0.3), value: currentIndex)
            }
        }
        .frame(height: 3)
    }

    // MARK: - Logic

    private func setup() {
        let pool = topic.map { t in allCards.filter { $0.topic == t } } ?? allCards
        sessionCards = Array(pool.shuffled().prefix(20))
        guard !sessionCards.isEmpty else { phase = .results; return }
        loadOptions(for: 0)
        phase = .question
    }

    private func restart() {
        currentIndex = 0; score = 0; missedCards = []
        selectedOption = nil
        sessionCards = sessionCards.shuffled()
        loadOptions(for: 0)
        phase = .question
    }

    private func loadOptions(for idx: Int) {
        guard idx < sessionCards.count else { return }
        let card = sessionCards[idx]

        // Distractors: other cards in same topic first, then any topic
        let sameTopicPool = allCards.filter { $0.id != card.id && $0.topic == card.topic }
        var distractors = sameTopicPool.shuffled().prefix(3).map { truncate($0.answer) }

        if distractors.count < 3 {
            let extra = allCards
                .filter { $0.id != card.id && !sameTopicPool.contains($0) }
                .shuffled()
                .prefix(3 - distractors.count)
                .map { truncate($0.answer) }
            distractors += extra
        }

        var opts = Array(distractors) + [truncate(card.answer)]
        opts.shuffle()
        correctIndex = opts.firstIndex(of: truncate(card.answer)) ?? 0
        options = opts
        selectedOption = nil
    }

    private func choose(_ index: Int, card: Flashcard) {
        guard selectedOption == nil else { return }
        selectedOption = index
        let correct = index == correctIndex
        if correct {
            score += 1
            SRSEngine.apply(rating: .good, to: card)
        } else {
            missedCards.append(card)
            SRSEngine.apply(rating: .again, to: card)
        }
        StreakManager.recordCardStudied()
        try? modelContext.save()
    }

    private func advance() {
        let next = currentIndex + 1
        if next >= sessionCards.count {
            phase = .results
        } else {
            currentIndex = next
            loadOptions(for: next)
        }
    }

    private func truncate(_ s: String) -> String {
        s.count > 130 ? String(s.prefix(130)) + "…" : s
    }
}

// MARK: - OptionButton

private struct OptionButton: View {
    let text: String
    let index: Int
    let selectedIndex: Int?
    let correctIndex: Int
    let action: () -> Void

    private enum State { case idle, correct, wrong, dim }

    private var state: State {
        guard let sel = selectedIndex else { return .idle }
        if index == correctIndex              { return .correct }
        if index == sel                       { return .wrong }
        return .dim
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Option letter A / B / C / D
                Text(["A", "B", "C", "D"][safe: index] ?? "")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundStyle(letterColor)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(letterBg))

                Text(text)
                    .font(.system(size: 15))
                    .foregroundStyle(state == .dim
                        ? Color.theme.textSecondary : Color.theme.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if selectedIndex != nil, state != .dim {
                    Image(systemName: state == .correct
                        ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(state == .correct
                        ? Color.theme.knownGreen : Color(hex: "#F87171"))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(bgFill)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(borderColor, lineWidth: 1))
            )
        }
        .buttonStyle(.plain)
        .disabled(selectedIndex != nil)
        .animation(.easeOut(duration: 0.2), value: selectedIndex)
    }

    private var letterColor: Color {
        switch state {
        case .idle:    return Color.theme.textSecondary
        case .correct: return Color.theme.background
        case .wrong:   return Color.theme.background
        case .dim:     return Color.theme.textSecondary.opacity(0.4)
        }
    }
    private var letterBg: Color {
        switch state {
        case .idle:    return Color.theme.separator
        case .correct: return Color.theme.knownGreen
        case .wrong:   return Color(hex: "#F87171")
        case .dim:     return Color.theme.separator.opacity(0.4)
        }
    }
    private var bgFill: Color {
        switch state {
        case .idle:    return Color.theme.surface
        case .correct: return Color.theme.knownGreen.opacity(0.12)
        case .wrong:   return Color(hex: "#F87171").opacity(0.12)
        case .dim:     return Color.theme.surface.opacity(0.4)
        }
    }
    private var borderColor: Color {
        switch state {
        case .idle:    return Color.theme.separator
        case .correct: return Color.theme.knownGreen.opacity(0.6)
        case .wrong:   return Color(hex: "#F87171").opacity(0.6)
        case .dim:     return Color.theme.separator.opacity(0.3)
        }
    }
}

// MARK: - QuizResultView

struct QuizResultView: View {
    let total: Int
    let score: Int
    let missedCards: [Flashcard]
    let onRetry: () -> Void
    let onDone:  () -> Void

    private var pct: Int { total > 0 ? Int(Double(score) / Double(total) * 100) : 0 }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 16)

                // Score ring
                ZStack {
                    Circle().stroke(Color.theme.separator, lineWidth: 10)
                        .frame(width: 140, height: 140)
                    Circle()
                        .trim(from: 0, to: CGFloat(pct) / 100)
                        .stroke(ringColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 0.8), value: pct)
                    VStack(spacing: 2) {
                        Text("\(pct)%")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(ringColor)
                        Text("\(score) / \(total)")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.theme.textSecondary)
                    }
                }

                Text(message)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.theme.textPrimary)

                // Missed cards
                if !missedCards.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Missed (\(missedCards.count))")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.theme.textSecondary)
                            .textCase(.uppercase).kerning(0.8)

                        ForEach(missedCards) { card in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(card.question).lineLimit(2)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color.theme.textPrimary)
                                Text(card.answer).lineLimit(3)
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.theme.textSecondary)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.theme.surface))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                VStack(spacing: 12) {
                    Button(action: onRetry) {
                        Text("Try Again")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.theme.background)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.theme.knownGreen))
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
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private var ringColor: Color {
        pct >= 80 ? Color.theme.knownGreen : pct >= 60 ? Color.theme.reviewAmber : Color(hex: "#F87171")
    }
    private var message: String {
        pct >= 90 ? "Excellent!" : pct >= 70 ? "Good work!" : pct >= 50 ? "Keep studying" : "Needs practice"
    }
}

// MARK: - Safe array subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
