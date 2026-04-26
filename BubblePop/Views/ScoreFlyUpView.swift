import SwiftUI

struct ScoreFlyUpView: View {
    let flyUp: ScoreFlyUp
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1

    var body: some View {
        HStack(spacing: 6) {
            Text("+\(flyUp.points)")
            if flyUp.isCombo {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
            }
        }
        .font(.system(size: 18, weight: .bold, design: .rounded))
        .foregroundStyle(flyUp.isCombo ? .orange : .green)
        .shadow(color: .black.opacity(0.5), radius: 2, y: 1)
        .offset(y: offset)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                offset = -50
                opacity = 0
            }
        }
    }
}
