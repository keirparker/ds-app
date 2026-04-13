import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionLabel: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60, weight: .light))
                .foregroundStyle(Color.theme.textSecondary)

            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.theme.textPrimary)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            if let label = actionLabel, let action {
                Button(action: action) {
                    Text(label)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.theme.textPrimary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.theme.surfaceElevated)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.theme.separator, lineWidth: 1)
                                )
                        )
                }
                .padding(.top, 8)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView(
        icon: "rectangle.stack.badge.magnifyingglass",
        title: "No Cards Found",
        message: "Try adjusting your filters or search query to find matching flashcards.",
        actionLabel: "Clear Filters",
        action: {}
    )
    .background(Color.theme.background)
}
