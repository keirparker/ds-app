import SwiftUI

struct FlashcardView: View {
    let card: Flashcard
    let onKnown: () -> Void
    let onReview: () -> Void
    var onSkip: (() -> Void)? = nil

    @State private var isFlipped: Bool = false
    @State private var dragOffset: CGSize = .zero
    @State private var rotation: Double = 0

    // Drag thresholds
    private let swipeThreshold: CGFloat = 120
    private let maxRotationDegrees: Double = 12

    // Overlay opacity driven by drag progress
    private var knownOverlayOpacity: Double {
        let progress = dragOffset.x / swipeThreshold
        return Double(max(0, min(progress, 1))) * 0.35
    }

    private var reviewOverlayOpacity: Double {
        let progress = -dragOffset.x / swipeThreshold
        return Double(max(0, min(progress, 1))) * 0.35
    }

    var body: some View {
        ZStack {
            // Card front
            CardFrontView(card: card)
                .flipEffect(angle: isFlipped ? 180 : 0)

            // Card back (pre-rotated 180° so it appears correct after flip)
            CardBackView(card: card, onKnown: handleKnown, onReview: handleReview)
                .flipEffect(angle: isFlipped ? 0 : -180)

            // Known swipe overlay (green, right drag)
            if dragOffset.x > 0 {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.theme.knownGreen.opacity(knownOverlayOpacity))
                    .allowsHitTesting(false)
            }

            // Review swipe overlay (amber, left drag)
            if dragOffset.x < 0 {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.theme.reviewAmber.opacity(reviewOverlayOpacity))
                    .allowsHitTesting(false)
            }
        }
        .cardStyle(accentColor: card.topic.accentColor)
        .offset(x: dragOffset.x)
        .rotationEffect(.degrees(rotation))
        .contentShape(Rectangle())
        .onTapGesture {
            flipCard()
        }
        .gesture(
            DragGesture(minimumDistance: 10)
                .onChanged { value in
                    dragOffset = CGSize(width: value.translation.width, height: 0)
                    rotation = Double(value.translation.width) / 15
                }
                .onEnded { value in
                    let dx = value.translation.width

                    if dx > swipeThreshold {
                        commitSwipe(direction: .right)
                    } else if dx < -swipeThreshold {
                        commitSwipe(direction: .left)
                    } else {
                        snapBack()
                    }
                }
        )
    }

    // MARK: - Actions

    private func flipCard() {
        withAnimation(.cardFlip) {
            isFlipped.toggle()
        }
    }

    private func handleKnown() {
        commitSwipe(direction: .right)
    }

    private func handleReview() {
        commitSwipe(direction: .left)
    }

    private func commitSwipe(direction: SwipeDirection) {
        let targetX: CGFloat = direction == .right ? 500 : -500
        let targetRotation: Double = direction == .right ? maxRotationDegrees : -maxRotationDegrees

        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            dragOffset = CGSize(width: targetX, height: 0)
            rotation = targetRotation
        }

        // Give the animation a moment before calling the callback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isFlipped = false
            dragOffset = .zero
            rotation = 0

            switch direction {
            case .right: onKnown()
            case .left:  onReview()
            }
        }
    }

    private func snapBack() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            dragOffset = .zero
            rotation = 0
        }
    }

    // MARK: - Helpers

    private enum SwipeDirection {
        case left, right
    }
}
