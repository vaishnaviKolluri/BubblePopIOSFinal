import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: GameSettings

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Game Time").font(.headline)
                        Spacer()
                        Text("\(settings.gameTime) seconds").foregroundStyle(.secondary).monospacedDigit()
                    }

                    Slider(
                        value: Binding(
                            get: { Double(settings.gameTime) },
                            set: { settings.gameTime = Int($0) }
                        ),
                        in: Double(GameSettings.timeRange.lowerBound)...Double(GameSettings.timeRange.upperBound),
                        step: 1
                    )

                    Text("Duration of each game (\(GameSettings.timeRange.lowerBound)–\(GameSettings.timeRange.upperBound) seconds)")
                        .font(.caption).foregroundStyle(.tertiary)
                }
            } header: {
                Text("Timer")
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Max Bubbles").font(.headline)
                        Spacer()
                        Text("\(settings.maxBubbles)").foregroundStyle(.secondary).monospacedDigit()
                    }
                    Slider(
                        value: Binding(
                            get: { Double(settings.maxBubbles) },
                            set: { settings.maxBubbles = Int($0) }
                        ),
                        in: Double(GameSettings.bubblesRange.lowerBound)...Double(GameSettings.bubblesRange.upperBound),
                        step: 1
                    )

                    Text("Maximum bubbles on screen at once (\(GameSettings.bubblesRange.lowerBound)–\(GameSettings.bubblesRange.upperBound))")
                        .font(.caption).foregroundStyle(.tertiary)
                }
            } header: {
                Text("Bubbles")
            }

            Section {
                ForEach(BubbleColour.allCases, id: \.self) { color in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(color.swiftUIColor)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle().strokeBorder(.gray.opacity(0.3), lineWidth: 1)
                            )

                        Text(color.displayName)
                        Spacer()
                        Text("\(color.points) pts")
                            .foregroundStyle(.secondary)

                        Text("(\(Int(color.probability * 100))%)")
                            .foregroundStyle(.tertiary)
                            .frame(width: 50, alignment: .trailing)
                    }
                }
            } header: {
                Text("Bubble Points & Probability")
            }

            Section {
                Button("Reset to Defaults") {
                    settings.gameTime = GameSettings.defaultTime
                    settings.maxBubbles = GameSettings.defaultBubbles
                }
                .foregroundStyle(.red)
            }
        }.navigationTitle("Settings")
    }
}
