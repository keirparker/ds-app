import SwiftUI
import SwiftData

struct TopicGridView: View {
    @Query private var allCards: [Flashcard]
    @Environment(AppEnvironment.self) private var env

    // Navigation state
    @State private var navigationPath = NavigationPath()
    @State private var quickStudyActive: Bool = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var reviewCards: [Flashcard] {
        allCards.filter(\.needsReview)
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Quick Study banner
                        quickStudyBanner

                        // Topic grid
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(Topic.allCases, id: \.self) { topic in
                                let topicCards = allCards.filter { $0.topic == topic }

                                TopicCardView(
                                    topic: topic,
                                    cards: topicCards,
                                    onTap: {
                                        navigationPath.append(TopicDestination.topic(topic))
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("DSFlash")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: TopicDestination.self) { destination in
                switch destination {
                case .topic(let topic):
                    DeckView(topic: topic, mode: .all)
                case .quickStudy:
                    DeckView(topic: nil, mode: .review)
                }
            }
        }
    }

    // MARK: - Quick Study banner

    private var quickStudyBanner: some View {
        Button {
            navigationPath.append(TopicDestination.quickStudy)
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.theme.reviewAmber.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.theme.reviewAmber)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Quick Study")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.theme.textPrimary)
                    Text("\(reviewCards.count) card\(reviewCards.count == 1 ? "" : "s") need review")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.theme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.theme.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.theme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.theme.reviewAmber.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Navigation destination enum

private enum TopicDestination: Hashable {
    case topic(Topic)
    case quickStudy
}

#Preview {
    TopicGridView()
        .environment(AppEnvironment())
        .modelContainer(for: Flashcard.self, inMemory: true)
}
