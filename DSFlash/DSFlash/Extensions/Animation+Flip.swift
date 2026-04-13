import SwiftUI

struct FlipModifier: AnimatableModifier {
    var angle: Double

    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0))
            .opacity(abs(angle) < 90 ? 1 : 0)
    }
}

extension View {
    func flipEffect(angle: Double) -> some View {
        modifier(FlipModifier(angle: angle))
    }
}

extension Animation {
    static var cardFlip: Animation {
        .spring(response: 0.4, dampingFraction: 0.8)
    }
}
