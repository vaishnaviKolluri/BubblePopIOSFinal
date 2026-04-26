import SwiftUI

struct BubbleView: View {
    let bubble: Bubble
    @State private var isAppearing = false

    var body: some View {
        ZStack {
            // Main circle
            Circle()
                .fill(bubble.bubbleColour.swiftUIColor)
                .frame(width: Bubble.radius * 2, height: Bubble.radius * 2)

            // Highlight for added dimension
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white.opacity(0.6), .clear],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: Bubble.radius * 0.8
                    )
                )
                .frame(width: Bubble.radius * 2, height: Bubble.radius * 2)

            // Border for better visibility
            Circle()
                .strokeBorder(.white.opacity(0.25), lineWidth: 1.5)
                .frame(width: Bubble.radius * 2, height: Bubble.radius * 2)

            // Points
            Text("\(bubble.points)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.4), radius: 1, y: 1)
        }
        .shadow(color: bubble.bubbleColour.swiftUIColor.opacity(0.4), radius: 4, y: 2)
        .scaleEffect(isAppearing ? 1.0 : 0.1)
        .onAppear {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                isAppearing = true
            }
        }
    }
}
