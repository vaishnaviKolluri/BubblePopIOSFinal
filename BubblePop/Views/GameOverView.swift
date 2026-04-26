import SwiftUI

struct GameOverView: View {
    let score: Int
    let playerName: String
    let isNewPersonalBest: Bool
    let onDismiss: () -> Void

    @EnvironmentObject var highScoreManager: HighScoreManager

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("Game Over!").font(.system(size: 36, weight: .bold, design: .rounded))

            Text("Score: \(score)")
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundStyle(.blue).monospacedDigit()

            if isNewPersonalBest {
                Text("New Personal Best!").font(.headline).foregroundStyle(.orange)
                Image(systemName: "trophy.fill").font(.title).foregroundStyle(.orange)
            }

            Divider().padding(.horizontal, 40)

            Text("High Scores").font(.title2.bold())

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(
                        Array(highScoreManager.scores.prefix(10).enumerated()),
                        id: \.element.id
                    ) { index, entry in
                        HStack {
                            Text("#\(index + 1)").font(.headline).foregroundStyle(.secondary)
                                .frame(width: 36, alignment: .leading)

                            if index == 0 {
                                Image(systemName: "crown.fill").foregroundStyle(.yellow)
                            }

                            Text(entry.name)
                                .fontWeight(isCurrentPlayer(entry) ? .bold : .regular).lineLimit(1)
                            Spacer()
                            Text("\(entry.score)")
                                .font(.headline.monospacedDigit())
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            isCurrentPlayer(entry)
                                ? Color.blue.opacity(0.1)
                                : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    if highScoreManager.scores.isEmpty {
                        Text("No scores yet!")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 24)
            }.frame(maxHeight: 300)

            Spacer()
            Button(action: onDismiss) {
                Text("Done")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
    }

    private func isCurrentPlayer(_ entry: HighScoreEntry) -> Bool {
        entry.name.lowercased() == playerName.lowercased()
    }
}
