import SwiftUI

struct CountdownOverlay: View {
    let value: Int
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0

    private var displayText: String {
        value > 0 ? "\(value)" : "Go!"
    }

    private var displayColour: Color {
        switch value {
        case 3: return .red
        case 2: return .orange
        case 1: return .yellow
        default: return .green
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()

            Text(displayText).font(.system(size: 100, weight: .bold, design: .rounded)).foregroundStyle(displayColour)
                .shadow(color: .black.opacity(0.3), radius: 6, y: 3).scaleEffect(scale).opacity(opacity)
        }
        .allowsHitTesting(false).onAppear { animate() }.onChange(of: value) { _, _ in animate() }
    }

    private func animate() {
        scale = 0.3
        opacity = 0

        withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
            scale = 1.1
            opacity = 1
        }

        withAnimation(.easeOut(duration: 0.2).delay(0.45)) {
            scale = 0.9
            opacity = 0
        }
    }
}
