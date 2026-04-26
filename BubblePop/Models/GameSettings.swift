import Combine
import Foundation

class GameSettings: ObservableObject {
    static let timeRange = 1...120
    static let bubblesRange = 1...30
    static let defaultTime = 60
    static let defaultBubbles = 15

    @Published var gameTime: Int = defaultTime
    @Published var maxBubbles: Int = defaultBubbles
    
    private var cancellables: Set<AnyCancellable> = []

    init() {
        let savedTime = UserDefaults.standard.integer(forKey: "gameTime")
        let savedBubbles = UserDefaults.standard.integer(forKey: "maxBubbles")
        self.gameTime = Self.timeRange.contains(savedTime) ? savedTime : Self.defaultTime
        self.maxBubbles = Self.bubblesRange.contains(savedBubbles) ? savedBubbles : Self.defaultBubbles

        $gameTime.dropFirst().sink { UserDefaults.standard.set($0, forKey: "gameTime") }.store(in: &cancellables)
        $maxBubbles.dropFirst().sink { UserDefaults.standard.set($0, forKey: "maxBubbles") }.store(in: &cancellables)
    }
}
