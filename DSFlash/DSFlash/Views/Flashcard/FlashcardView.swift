import SwiftUI

struct FlashcardView: View {
    let card: Flashcard
    var onRate: (SRSRating) -> Void = { _ in }

    @State private var isFlipped: Bool = false
    @State private var frontAngle: Double = 0
    @State private var backAngle: Double = 90

    var body: some View {
        VStack(spacing: 20) {
            // Card stack
            ZStack {
                CardFrontView(card: card)
                    .flipEffect(angle: frontAngle)

                CardBackView(card: card)
                    .flipEffect(angle: backAngle)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 420)
            .onTapGesture { flip() }

            // SRS rating buttons — appear after flip
            if isFlipped {
                ratingButtons
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                Text("Tap card to reveal answer")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.theme.textSecondary)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, 20)
        .onChange(of: card.id) { _, _ in resetCard() }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isFlipped)
    }

    // MARK: - Rating buttons

    private var ratingButtons: some View {
        VStack(spacing: 10) {
            // Next-review hint
            HStack(spacing: 16) {
                ForEach(SRSRating.allCases, id: \.rawValue) { rating in
                    Text(nextHint(rating))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(rating.color.opacity(0.7))
                        .frame(maxWidth: .infinity)
                }
            }

            // Buttons
            HStack(spacing: 10) {
                ForEach(SRSRating.allCases, id: \.rawValue) { rating in
                    RatingButton(rating: rating) {
                        onRate(rating)
                        resetCard()
                    }
                }
            }
        }
    }

    private func nextHint(_ rating: SRSRating) -> String {
        switch rating {
        case .again: return "< 1d"
        case .hard:  return "1d"
        case .good:
            let next = Int((Double(max(1, card.srsInterval)) * card.srsEaseFactor).rounded())
            return "\(next)d"
        case .easy:
            let next = Int((Double(max(1, card.srsInterval)) * max(card.srsEaseFactor, 2.5)).rounded())
            return "~\(next)d"
        }
    }

    // MARK: - Flip logic

    private func flip() {
        withAnimation(.cardFlip) {
            if isFlipped {
                frontAngle = 0
                backAngle  = 90
            } else {
                frontAngle = -90
                backAngle  = 0
            }
            isFlipped.toggle()
        }
    }

    private func resetCard() {
        isFlipped  = false
        frontAngle = 0
        backAngle  = 90
    }
}

// MARK: - RatingButton

private struct RatingButton: View {
    let rating: SRSRating
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: rating.icon)
                    .font(.system(size: 17, weight: .semibold))
                Text(rating.label)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundStyle(rating.color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(rating.color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(rating.color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
