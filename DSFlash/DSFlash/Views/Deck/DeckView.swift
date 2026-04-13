import SwiftUI
import SwiftData

struct DeckView: View {
    let topic: Topic?
    let mode: StudyMode

    init(topic: Topic? = nil, mode: StudyMode = .all) {
        self.topic = topic
        self.mode = mode
    }

    @Query private var allCards: [Flashcard]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var currentIndex: Int = 0
    @State private var showingCompletion: Bool = false

    // MARK: - Filtered cards

    private var cards: [Flashcard] {
        allCards.filter { card in
            let topicMatch = topic == nil || card.topic == topic
            let modeMatch: Bool
            switch mode {
            case .all:    modeMatch = true
            case .review: modeMatch = card.needsReview
            case .unseen: modeMatch = card.seenCount == 0
            }
            return topicMatch && modeMatch
        }
    }

    private var accentColor: Color {
        topic?.accentColor ?? Color.theme.knownGreen
    }

    private var deckTitle: String {
        if let topic {
            return "\(topic.emoji) \(topic.rawValue)"
        }
        switch mode {
        case .all:    return "All Cards"
        case .review: return "Needs Review"
        case .unseen: return "Unseen Cards"
        }
    }

    // MARK: - Stats for completion screen

    private var knownCount: Int {
        cards.filter(\.isKnown).count
    }

    private var reviewCount: Int {
        cards.filter(\.needsReview).count
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()

                Group {
                    if cards.isEmpty {
                        EmptyStateView(
                            icon: "rectangle.stack.badge.xmark",
                            title: "No Cards",
                            message: "There are no flashcards matching this selection.",
                            actionLabel: "Go Back",
                            action: { dismiss() }
                        )
                    } else if showingCompletion {
                        completionScreen
                    } else {
                        studyContent
                    }
                }
            }
            .navigationTitle(deckTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !cards.isEmpty && !showingCompletion {
                    ToolbarItem(placement: .principal) {
                        DeckProgressBar(
                            current: min(currentIndex + 1, cards.count),
                            total: cards.count,
                            accentColor: accentColor
                        )
                        .frame(width: 200)
                    }
                }
            }
        }
    }

    // MARK: - Study content

    private var studyContent: some View {
        VStack {
            Spacer()

            FlashcardView(
                card: cards[currentIndex],
                onKnown: {
                    let card = cards[currentIndex]
                    card.isKnown = true
                    card.lastSeenAt = Date()
                    card.seenCount += 1
                    try? modelContext.save()
                    advanceIndex()
                },
                onReview: {
                    let card = cards[currentIndex]
                    card.needsReview = true
                    card.lastSeenAt = Date()
                    card.seenCount += 1
                    try? modelContext.save()
                    advanceIndex()
                },
                onSkip: {
                    advanceIndex()
                }
            )
            .padding(.horizontal, 20)

            Spacer()
        }
    }

    // MARK: - Completion screen

    private var completionScreen: some View {
        VStack(spacing: 28) {
            Spacer()

            // Checkmark circle
            ZStack {
                Circle()
                    .fill(Color.theme.knownGreen.opacity(0.15))
                    .frame(width: 120, height: 120)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72, weight: .light))
                    .foregroundStyle(Color.theme.knownGreen)
            }

            // Title
            VStack(spacing: 8) {
                Text("Deck Complete!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.theme.textPrimary)

                Text("You've reviewed all \(cards.count) cards")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.theme.textSecondary)
            }

            // Stats pills
            HStack(spacing: 16) {
                StatPill(
                    label: "Known",
                    count: knownCount,
                    color: Color.theme.knownGreen
                )
                StatPill(
                    label: "To Review",
                    count: reviewCount,
                    color: Color.theme.reviewAmber
                )
                StatPill(
                    label: "Total",
                    count: cards.count,
                    color: Color.theme.textSecondary
                )
            }

            Spacer()

            // Actions
            VStack(spacing: 12) {
                Button {
                    currentIndex = 0
                    showingCompletion = false
                } label: {
                    Text("Study Again")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(accentColor)
                        )
                }

                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.theme.surface)
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Helpers

    private func advanceIndex() {
        if currentIndex + 1 >= cards.count {
            showingCompletion = true
        } else {
            currentIndex += 1
        }
    }
}

// MARK: - Supporting views

private struct StatPill: View {
    let label: String
    let count: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.theme.textSecondary)
        }
        .frame(minWidth: 72)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
