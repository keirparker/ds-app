import SwiftUI
import SwiftData

struct ProgressDashboardView: View {
    @Query private var allCards: [Flashcard]
    @Environment(\.modelContext) private var modelContext

    @State private var showingResetConfirmation: Bool = false

    // MARK: - Computed stats

    private var knownCount: Int  { allCards.filter(\.isKnown).count }
    private var reviewCount: Int { allCards.filter { $0.needsReview && !$0.isKnown }.count }
    private var unseenCount: Int { allCards.filter { !$0.isKnown && !$0.needsReview }.count }
    private var totalCount: Int  { allCards.count }

    private var overallProgress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(knownCount) / Double(totalCount)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        overallSection
                        topicsSection
                        resetSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
        }
        .confirmationDialog(
            "Reset All Progress",
            isPresented: $showingResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset All Progress", role: .destructive) {
                resetAllProgress()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will clear all \"Known\" and \"Needs Review\" marks. This action cannot be undone.")
        }
    }

    // MARK: - Overall section

    private var overallSection: some View {
        VStack(spacing: 20) {
            // Large circular progress
            CircularProgressView(
                progress: overallProgress,
                color: Color.theme.knownGreen,
                size: 120,
                lineWidth: 10
            )

            Text("Overall Mastery")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.theme.textSecondary)

            // Stat pills row
            HStack(spacing: 12) {
                StatsPill(label: "Known",   count: knownCount,  color: Color.theme.knownGreen)
                StatsPill(label: "Review",  count: reviewCount, color: Color.theme.reviewAmber)
                StatsPill(label: "Unseen",  count: unseenCount, color: Color.theme.textSecondary)
            }
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.theme.surface)
        )
    }

    // MARK: - Topics section

    private var topicsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("By Topic")
                .sectionHeader()
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                ForEach(Topic.allCases, id: \.self) { topic in
                    let topicCards = allCards.filter { $0.topic == topic }

                    TopicProgressRow(topic: topic, cards: topicCards)
                        .padding(.horizontal, 16)

                    if topic != Topic.allCases.last {
                        Divider()
                            .background(Color.theme.separator)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.theme.surface)
            )
        }
    }

    // MARK: - Reset section

    private var resetSection: some View {
        Button {
            showingResetConfirmation = true
        } label: {
            Label("Reset All Progress", systemImage: "arrow.counterclockwise")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.red.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }

    // MARK: - Actions

    private func resetAllProgress() {
        for card in allCards {
            card.isKnown = false
            card.needsReview = false
        }
        try? modelContext.save()
    }
}

// MARK: - Supporting views

private struct StatsPill: View {
    let label: String
    let count: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(color)
                .monospacedDigit()
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

#Preview {
    ProgressDashboardView()
        .modelContainer(for: Flashcard.self, inMemory: true)
}
