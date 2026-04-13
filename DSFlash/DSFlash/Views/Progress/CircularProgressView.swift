import SwiftUI

struct CircularProgressView: View {
    let progress: Double    // 0.0 – 1.0
    let color: Color
    var size: CGFloat = 44
    var lineWidth: CGFloat = 4

    @State private var animatedProgress: Double = 0

    private var clampedProgress: Double {
        max(0, min(1, progress))
    }

    private var percentageText: String {
        "\(Int(clampedProgress * 100))%"
    }

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.theme.separator, lineWidth: lineWidth)

            // Foreground fill
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animatedProgress)

            // Percentage label
            Text(percentageText)
                .font(.system(size: size * 0.25, weight: .bold))
                .foregroundStyle(Color.theme.textPrimary)
                .minimumScaleFactor(0.5)
        }
        .frame(width: size, height: size)
        .onAppear {
            animatedProgress = clampedProgress
        }
        .onChange(of: progress) { _, newValue in
            animatedProgress = max(0, min(1, newValue))
        }
    }
}

#Preview {
    HStack(spacing: 24) {
        CircularProgressView(progress: 0.72, color: Color.theme.knownGreen, size: 120, lineWidth: 10)
        CircularProgressView(progress: 0.45, color: Color.theme.reviewAmber, size: 80, lineWidth: 8)
        CircularProgressView(progress: 0.2, color: Color.theme.blue, size: 44, lineWidth: 4)
    }
    .padding()
    .background(Color.theme.background)
}
