import SwiftUI
import SwiftData

struct SearchView: View {
    @Query private var allCards: [Flashcard]

    @State private var searchText: String = ""
    @State private var selectedCard: Flashcard? = nil

    // MARK: - Filtered results

    private var filteredCards: [Flashcard] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        let query = searchText.lowercased()
        return allCards.filter {
            $0.question.lowercased().contains(query) ||
            $0.answer.lowercased().contains(query)
        }
    }

    private var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()

                Group {
                    if !isSearching {
                        placeholderPrompt
                    } else if filteredCards.isEmpty {
                        EmptyStateView(
                            icon: "magnifyingglass",
                            title: "No Results",
                            message: "No flashcards match \"\(searchText)\". Try a different query."
                        )
                    } else {
                        resultsList
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search questions & answers…"
            )
        }
        .sheet(item: $selectedCard) { card in
            CardDetailSheet(card: card)
        }
    }

    // MARK: - Sub-views

    private var placeholderPrompt: some View {
        VStack(spacing: 16) {
            Image(systemName: "text.magnifyingglass")
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(Color.theme.textSecondary)

            Text("Search Flashcards")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.theme.textPrimary)

            Text("Type a keyword to search across all\nquestions and answers.")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }

    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                Text("\(filteredCards.count) result\(filteredCards.count == 1 ? "" : "s")")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.theme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)

                ForEach(filteredCards) { card in
                    SearchResultRow(card: card)
                        .onTapGesture {
                            selectedCard = card
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Card detail sheet

private struct CardDetailSheet: View {
    let card: Flashcard
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()

                FlashcardView(
                    card: card,
                    onKnown: { dismiss() },
                    onReview: { dismiss() },
                    onSkip: { dismiss() }
                )
                .padding(.horizontal, 20)
            }
            .navigationTitle("Card Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.theme.knownGreen)
                }
            }
        }
    }
}

#Preview {
    SearchView()
        .modelContainer(for: Flashcard.self, inMemory: true)
}
