import SwiftUI

struct HighScoreView: View {
    @EnvironmentObject var highScoreManager: HighScoreManager

    var body: some View {
        List {
            if highScoreManager.scores.isEmpty {
                ContentUnavailableView(
                    "No Scores Yet",
                    systemImage: "trophy",
                    description: Text("Play a game to set the first high score!")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(
                    Array(highScoreManager.scores.enumerated()),
                    id: \.element.id
                ) { index, entry in
                    HStack(spacing: 12) {
                        // Rank
                        ZStack {
                            Circle()
                                .fill(rankColour(index))
                                .frame(width: 32, height: 32)

                            Text("\(index + 1)")
                                .font(.callout.bold())
                                .foregroundStyle(.white)
                        }

                        // Crown for 1st
                        if index == 0 {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.yellow)
                        }

                        Text(entry.name)
                            .font(.body.bold())
                            .lineLimit(1)

                        Spacer()

                        // Score
                        Text("\(entry.score)")
                            .font(.title3.monospacedDigit())
                            .foregroundStyle(.blue)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("High Scores")
        .onAppear {
            highScoreManager.loadScores()
        }
    }

    private func rankColour(_ index: Int) -> Color {
        switch index {
        case 0: return .yellow
        case 1: return .gray
        case 2: return .orange
        default: return .blue.opacity(0.5)
        }
    }
}
