import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var settings: GameSettings
    @EnvironmentObject var highScoreManager: HighScoreManager
    @State private var playerName: String = ""

    private var trimmedName: String {
        playerName.trimmingCharacters(in: .whitespaces)
    }

    private var canStart: Bool {
        !trimmedName.isEmpty
    }

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            // Title
            VStack(spacing: 8) {
                Text("BubblePop!")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("Pop bubbles. Score points. Be the best!").font(.subheadline).foregroundStyle(.secondary)
            }

            // Name entry
            VStack(alignment: .leading, spacing: 8) {
                Text("Player Name").font(.headline)

                TextField("Enter your name", text: $playerName)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
            }.padding(.horizontal, 40)

            // Play button
            NavigationLink(
                destination: GameView(
                    playerName: trimmedName,
                    settings: settings,
                    highScoreManager: highScoreManager
                )
            ) {
                Text("▶ Play!")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canStart ? Color.blue : Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(!canStart)
            .padding(.horizontal, 40)
            Spacer()
            
            // Bottom navigation
            HStack(spacing: 40) {
                NavigationLink(destination: SettingsView()) {
                    Label("Settings", systemImage: "gearshape.fill").font(.body.bold())
                }

                NavigationLink(destination: HighScoreView()) {
                    Label("High Scores", systemImage: "trophy.fill").font(.body.bold())
                }
            }
            .padding(.bottom, 30)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
