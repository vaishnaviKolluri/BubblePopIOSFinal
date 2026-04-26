import SwiftUI

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    @EnvironmentObject var highScoreManager: HighScoreManager
    @Environment(\.dismiss) private var dismiss

    init(playerName: String, settings: GameSettings, highScoreManager: HighScoreManager) {
        _viewModel = StateObject(wrappedValue: GameViewModel(
            playerName: playerName,
            settings: settings,
            highScoreManager: highScoreManager
        ))
    }

    var body: some View {
        ZStack {
            if viewModel.isGameOver {
                GameOverView(
                    score: viewModel.score,
                    playerName: viewModel.playerName,
                    isNewPersonalBest: viewModel.isNewPersonalBest,
                    onDismiss: { dismiss() }
                )
                .transition(.opacity)
            } else {
                gameplayContent
            }
        }
        .animation(.easeInOut(duration: 0.4), value: viewModel.isGameOver)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }

    private var gameplayContent: some View {
        VStack(spacing: 0) {
            hudBar
                .zIndex(1)

            // Game Area
            GeometryReader { geometry in
                ZStack {
                    Color(.systemBackground)

                    // Bubbles
                    ForEach(viewModel.bubbles) { bubble in
                        BubbleView(bubble: bubble)
                            .position(bubble.position)
                            .transition(.scale.combined(with: .opacity))
                            .onTapGesture {
                                withAnimation(.easeOut(duration: 0.15)) {
                                    viewModel.popBubble(bubble)
                                }
                            }
                    }

                    // Score flyups
                    ForEach(viewModel.scoreFlyUps) { flyUp in
                        ScoreFlyUpView(flyUp: flyUp)
                            .position(flyUp.position)
                            .allowsHitTesting(false)
                    }

                    // Countdown
                    if viewModel.isCountingDown {
                        CountdownOverlay(value: viewModel.countdownValue)
                    }
                }
                .onAppear {
                    viewModel.setScreenSize(geometry.size)
                    viewModel.startCountdown()
                }
                .onChange(of: geometry.size) { _, newSize in
                    viewModel.setScreenSize(newSize)
                }
            }
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }


    private var hudBar: some View {
        HStack {
            // Timer
            HStack(spacing: 4) {
                Image(systemName: "timer")
                Text("\(viewModel.timeRemaining)").monospacedDigit()
            }
            .font(.title2.bold())
            .foregroundStyle(viewModel.timeRemaining <= 10 ? .red : .primary)

            Spacer()

            // Combo indicator
            if viewModel.comboCount > 1 {
                HStack(spacing: 6){
                    Text("x\(viewModel.comboCount)")
                    Image(systemName: "flame.fill")
                        .font(.headline)
                        .foregroundStyle(.orange)
                        .transition(.scale.combined(with: .opacity))
                }
            }

            Spacer()

            // Score + High score
            VStack(alignment: .trailing, spacing: 2) {
                Text("Best: \(viewModel.currentHighScore)").font(.caption.bold()).foregroundStyle(.secondary)

                Text("Score: \(viewModel.score)").font(.title.bold()).foregroundStyle(.purple).monospacedDigit()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }
}
