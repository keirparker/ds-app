import SwiftUI

struct CardBackView: View {
    let card: Flashcard
    let onKnown: () -> Void
    let onReview: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            // Left accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(card.topic.accentColor)
                .frame(width: 4)
                .padding(.vertical, 28)

            VStack(alignment: .leading, spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Answer
                        Text(card.answer)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.theme.textPrimary)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 20)

                        // Divider with "Explanation" label
                        HStack(spacing: 10) {
                            Rectangle()
                                .fill(Color.theme.separator)
                                .frame(height: 1)
                                .frame(width: 24)

                            Text("Explanation")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.theme.textSecondary)
                                .textCase(.uppercase)
                                .kerning(1.0)

                            Rectangle()
                                .fill(Color.theme.separator)
                                .frame(height: 1)
                        }
                        .padding(.bottom, 16)

                        // Explanation
                        Text(card.explanation)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color.theme.textSecondary)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 8)
                    }
                }

                // Action buttons
                HStack(spacing: 12) {
                    // Got it button
                    Button(action: onKnown) {
                        Label("Got it", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.theme.knownGreen)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.theme.knownGreen.opacity(0.15))
                            )
                    }

                    // Review button
                    Button(action: onReview) {
                        Label("Review", systemImage: "arrow.uturn.backward.circle.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.theme.reviewAmber)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.theme.reviewAmber.opacity(0.15))
                            )
                    }
                }
                .padding(.top, 16)
            }
            .padding(28)
        }
    }
}
