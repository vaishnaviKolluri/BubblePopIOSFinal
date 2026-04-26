import SwiftUI

@main
struct BubblePopApp: App {
    @StateObject private var settings = GameSettings()
    @StateObject private var highScoreManager = HighScoreManager()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                WelcomeView()
            }
            .environmentObject(settings)
            .environmentObject(highScoreManager)
        }
    }
}
