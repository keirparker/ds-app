import SwiftUI
import SwiftData

struct TopicGridView: View {
    @Query private var allCards: [Flashcard]
    @Environment(AppEnvironment.self) private var env

    @State private var navigationPath = NavigationPath()
    @State private var showQuiz = false
    @State private var showSim  = false

    // Streak state — refreshed on appear
    @State private var streak: Int = 0
    @State private var cardsToday: Int = 0

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var dueCount: Int    { SRSEngine.dueCount(from: allCards) }
    private var reviewCount: Int { allCards.filter(\.needsReview).count }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color.theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Streak / daily goal header
                        StreakHeaderView(
                            streak: streak,
                            cardsToday: cardsToday,
                            dailyGoal: StreakManager.dailyGoal
                        )

                        VStack(spacing: 20) {
                            // Study mode cards
                            studyModeSection

                            // Divider
                            HStack {
                                Text("Topics")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Color.theme.textSecondary)
                                    .textCase(.uppercase).kerning(0.8)
                                Spacer()
                            }

                            // Topic grid
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(Topic.allCases, id: \.self) { topic in
                                    let topicCards = allCards.filter { $0.topic == topic }
                                    TopicCardView(
                                        topic: topic,
                                        cards: topicCards,
                                        onTap: { navigationPath.append(Dest.topic(topic)) }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("DSFlash")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Dest.self) { dest in
                switch dest {
                case .topic(let t):    DeckView(topic: t, mode: .all)
                case .dueToday:        DeckView(topic: nil, mode: .dueToday)
                case .quickStudy:      DeckView(topic: nil, mode: .review)
                }
            }
        }
        .sheet(isPresented: $showQuiz) { QuizView(topic: nil) }
        .sheet(isPresented: $showSim)  { InterviewSimulationView() }
        .onAppear { refreshStreak() }
    }

    // MARK: - Study mode section

    private var studyModeSection: some View {
        VStack(spacing: 10) {
            // Due Today (SRS)
            StudyModeButton(
                icon: "clock.arrow.2.circlepath",
                title: "Due Today",
                subtitle: dueCount == 0
                    ? "All caught up!"
                    : "\(dueCount) card\(dueCount == 1 ? "" : "s") scheduled for review",
                accentColor: Color.theme.blue,
                badge: dueCount > 0 ? "\(dueCount)" : nil
            ) { navigationPath.append(Dest.dueToday) }

            HStack(spacing: 10) {
                // Quiz
                StudyModeButton(
                    icon: "questionmark.circle.fill",
                    title: "Quiz",
                    subtitle: "4-option multiple choice",
                    accentColor: Color.theme.violet,
                    badge: nil
                ) { showQuiz = true }

                // Interview Sim
                StudyModeButton(
                    icon: "timer",
                    title: "Interview Sim",
                    subtitle: "Timed mock session",
                    accentColor: Color.theme.reviewAmber,
                    badge: nil
                ) { showSim = true }
            }

            // Quick Study (needs review)
            if reviewCount > 0 {
                StudyModeButton(
                    icon: "bolt.fill",
                    title: "Quick Study",
                    subtitle: "\(reviewCount) card\(reviewCount == 1 ? "" : "s") need review",
                    accentColor: Color.theme.gold,
                    badge: nil
                ) { navigationPath.append(Dest.quickStudy) }
            }
        }
    }

    // MARK: - Helpers

    private func refreshStreak() {
        streak = StreakManager.currentStreak
        cardsToday = StreakManager.cardsStudiedToday
    }
}

// MARK: - Navigation destinations

private enum Dest: Hashable {
    case topic(Topic)
    case dueToday
    case quickStudy
}

// MARK: - StudyModeButton

private struct StudyModeButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let accentColor: Color
    let badge: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 42, height: 42)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(accentColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.theme.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.theme.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                if let badge {
                    Text(badge)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.theme.background)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Capsule().fill(accentColor))
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.theme.textSecondary)
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.theme.surface)
                    .overlay(RoundedRectangle(cornerRadius: 16)
                        .stroke(accentColor.opacity(0.25), lineWidth: 1))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - StreakHeaderView

struct StreakHeaderView: View {
    let streak: Int
    let cardsToday: Int
    let dailyGoal: Int

    private var progress: Double {
        dailyGoal > 0 ? min(1, Double(cardsToday) / Double(dailyGoal)) : 0
    }
    private var isComplete: Bool { cardsToday >= dailyGoal }

    var body: some View {
        HStack(spacing: 0) {
            // Streak
            HStack(spacing: 8) {
                Text("🔥")
                    .font(.system(size: 22))
                VStack(alignment: .leading, spacing: 1) {
                    Text("\(streak)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.theme.textPrimary)
                    Text("day streak")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.theme.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Daily goal
            VStack(alignment: .trailing, spacing: 5) {
                Text(isComplete ? "Goal complete ✓" : "\(cardsToday) / \(dailyGoal) today")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isComplete ? Color.theme.knownGreen : Color.theme.textSecondary)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.theme.separator).frame(height: 5)
                        Capsule()
                            .fill(isComplete ? Color.theme.knownGreen : Color.theme.reviewAmber)
                            .frame(width: geo.size.width * progress, height: 5)
                            .animation(.easeOut(duration: 0.4), value: progress)
                    }
                }
                .frame(width: 110, height: 5)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.theme.surface)
        .overlay(Rectangle().fill(Color.theme.separator).frame(height: 1), alignment: .bottom)
    }
}

#Preview {
    TopicGridView()
        .environment(AppEnvironment())
        .modelContainer(for: Flashcard.self, inMemory: true)
}
