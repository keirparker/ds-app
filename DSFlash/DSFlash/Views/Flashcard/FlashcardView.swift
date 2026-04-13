import SwiftUI

struct FlashcardView: View {
    let card: Flashcard
    var onKnown: () -> Void = {}
    var onReview: () -> Void = {}
    var onSkip: () -> Void = {}

    @State private var isFlipped: Bool = false
    @State private var frontAngle: Double = 0
    @State private var backAngle: Double = 90

    var body: some View {
        VStack(spacing: 24) {
            // Card
            ZStack {
                CardFrontView(card: card)
                    .flipEffect(angle: frontAngle)

                CardBackView(card: card)
                    .flipEffect(angle: backAngle)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 420)
            .onTapGesture {
                flip()
            }

            // Action buttons (only visible when flipped)
            if isFlipped {
                HStack(spacing: 16) {
                    // Review
                    ActionButton(
                        label: "Review",
                        icon: "bookmark.fill",
                        color: Color.theme.reviewAmber
                    ) {
                        onReview()
                    }

                    // Skip
                    ActionButton(
                        label: "Skip",
                        icon: "arrow.right",
                        color: Color.theme.textSecondary
                    ) {
                        onSkip()
                    }

                    // Known
                    ActionButton(
                        label: "Got It",
                        icon: "checkmark",
                        color: Color.theme.knownGreen
                    ) {
                        onKnown()
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 20)
        .onChange(of: card.id) { _, _ in
            resetCard()
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isFlipped)
    }

    // MARK: - Private

    private func flip() {
        withAnimation(.cardFlip) {
            if isFlipped {
                frontAngle = 0
                backAngle = 90
            } else {
                frontAngle = -90
                backAngle = 0
            }
            isFlipped.toggle()
        }
    }

    private func resetCard() {
        isFlipped = false
        frontAngle = 0
        backAngle = 90
    }
}

// MARK: - ActionButton

private struct ActionButton: View {
    let label: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(label)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
