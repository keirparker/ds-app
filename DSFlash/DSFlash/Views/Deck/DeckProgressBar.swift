import SwiftUI

struct DeckProgressBar: View {
    let current: Int
    let total: Int
    let accentColor: Color

    @State private var animatedProgress: CGFloat = 0

    private var progress: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(current) / CGFloat(total)
    }

    var body: some View {
        VStack(spacing: 4) {
            Text("Card \(current) of \(total)")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(Color.theme.textSecondary)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track
                    Capsule()
                        .fill(Color.theme.separator)
                        .frame(height: 6)

                    // Fill
                    Capsule()
                        .fill(accentColor)
                        .frame(width: geometry.size.width * animatedProgress, height: 6)
                        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: animatedProgress)
                }
            }
            .frame(height: 6)
        }
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: current) { _, _ in
            animatedProgress = progress
        }
        .onChange(of: total) { _, _ in
            animatedProgress = progress
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        DeckProgressBar(current: 3, total: 10, accentColor: .blue)
        DeckProgressBar(current: 7, total: 10, accentColor: Color.theme.knownGreen)
        DeckProgressBar(current: 10, total: 10, accentColor: Color.theme.reviewAmber)
    }
    .padding()
    .background(Color.theme.background)
}
