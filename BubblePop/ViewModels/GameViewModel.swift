import SwiftUI
import Combine

class GameViewModel: ObservableObject {

    @Published var bubbles: [Bubble] = []
    @Published var score: Int = 0
    @Published var timeRemaining: Int
    @Published var isGameOver: Bool = false
    @Published var isCountingDown: Bool = true
    @Published var countdownValue: Int = 3
    @Published var comboCount: Int = 0
    @Published var lastPoppedcolour: BubbleColour? = nil
    @Published var scoreFlyUps: [ScoreFlyUp] = []
    @Published var isNewPersonalBest: Bool = false


    let maxBubbles: Int
    let totalGameTime: Int
    let playerName: String
    let highScoreManager: HighScoreManager


    private var gameTimer: AnyCancellable?
    private var countdownTimer: AnyCancellable?
    private var moveTimer: AnyCancellable?
    private(set) var screenSize: CGSize = .zero

    var movementSpeed: CGFloat {
        guard totalGameTime > 0 else { return 1.0 }
        let elapsed = CGFloat(totalGameTime - timeRemaining)
        let progress = elapsed / CGFloat(totalGameTime)
        return 1.0 + progress * 2.0
    }

    var currentHighScore: Int {
        highScoreManager.highestScore
    }

    init(playerName: String, settings: GameSettings, highScoreManager: HighScoreManager) {
        self.playerName = playerName
        self.totalGameTime = settings.gameTime
        self.maxBubbles = settings.maxBubbles
        self.timeRemaining = settings.gameTime
        self.highScoreManager = highScoreManager
    }

    func setScreenSize(_ size: CGSize) {
        let oldSize = screenSize
        screenSize = size

        if oldSize != .zero && oldSize != size {
            let r = Bubble.radius
            bubbles.removeAll { bubble in
                bubble.position.x - r < 0 || bubble.position.x + r > size.width ||
                bubble.position.y - r < 0 || bubble.position.y + r > size.height
            }
        }
    }

    // Pre-game countdown
    func startCountdown() {
        isCountingDown = true
        countdownValue = 3
        countdownTimer = Timer.publish(every: 0.8, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.countdownValue -= 1
                if self.countdownValue < 0 {
                    self.countdownTimer?.cancel()
                    self.isCountingDown = false
                    self.startGame()
                }
            }
    }

    private func startGame() {
        refreshBubbles()
        startMovement()

        gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timeRemaining > 1 {
                    self.timeRemaining -= 1
                    
                    // Refresh bubbles every second
                    self.refreshBubbles()
                } else {
                    self.timeRemaining = 0
                    self.endGame()
                }
            }
    }

    // Starts a timer to update bubble positions
    private func startMovement() {
        moveTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.updateBubblePositions()
            }
    }

    private func updateBubblePositions() {
        let speed = movementSpeed
        var indicesToRemove: [Int] = []
        for i in bubbles.indices {
            bubbles[i].position.x += bubbles[i].velocity.dx * speed
            bubbles[i].position.y += bubbles[i].velocity.dy * speed

            let pos = bubbles[i].position
            let r = Bubble.radius
            
            // Removes bubbles that leave the screen bounds
            if pos.x < -r || pos.x > screenSize.width + r ||
               pos.y < -r || pos.y > screenSize.height + r {
                indicesToRemove.append(i)
            }
        }

        for i in indicesToRemove.reversed() {
            bubbles.remove(at: i)
        }
    }


    // Refresh bubbles
    private func refreshBubbles() {
        let removeCount = Int.random(in: 0...max(0, bubbles.count / 2))
        for _ in 0..<removeCount {
            if !bubbles.isEmpty {
                let idx = Int.random(in: 0..<bubbles.count)
                bubbles.remove(at: idx)
            }
        }

        let targetCount = Int.random(in: max(1, maxBubbles / 2)...maxBubbles)
        let bubblesNeeded = max(0, targetCount - bubbles.count)

        for _ in 0..<bubblesNeeded {
            if let bubble = createRandomBubble() {
                bubbles.append(bubble)
            }
        }
    }

    // Creates a single bubble with random colour and velocity
    private func createRandomBubble() -> Bubble? {
        guard let position = findValidPosition() else { return nil }
        let colour = weightedRandomColour()
        let velocity = randomVelocity()
        return Bubble(bubbleColour: colour, position: position, velocity: velocity)
    }
    
    // Finds valid position for spawning a bubble
    private func findValidPosition() -> CGPoint? {
        let r = Bubble.radius
        guard screenSize.width > r * 2, screenSize.height > r * 2 else { return nil }

        let minX = r
        let maxX = screenSize.width - r
        let minY = r
        let maxY = screenSize.height - r

        for _ in 0..<100 {
            let candidate = CGPoint(
                x: CGFloat.random(in: minX...maxX),
                y: CGFloat.random(in: minY...maxY)
            )

            let hasOverlap = bubbles.contains { existing in
                let dx = existing.position.x - candidate.x
                let dy = existing.position.y - candidate.y
                return sqrt(dx * dx + dy * dy) < (r * 2 + 4)
            }

            if !hasOverlap {
                return candidate
            }
        }
        return nil
    }

    // Returns a colour based on probabilities
    private func weightedRandomColour() -> BubbleColour {
        let rand = Double.random(in: 0..<1)
        var cumulative: Double = 0
        for colour in BubbleColour.allCases {
            cumulative += colour.probability
            if rand < cumulative { return colour }
        }
        return .red
    }

    // Produces a random movement vector
    private func randomVelocity() -> CGVector {
        let angle = Double.random(in: 0..<(2 * .pi))
        let magnitude = Double.random(in: 0.3...0.8)
        return CGVector(dx: cos(angle) * magnitude, dy: sin(angle) * magnitude)
    }

    // Handles a bubble pop
    func popBubble(_ bubble: Bubble) {
        guard let index = bubbles.firstIndex(where: { $0.id == bubble.id }) else { return }

        var pointsEarned = bubble.points

        // 1.5× for consecutive same colour pops
        if let lastcolour = lastPoppedcolour, lastcolour == bubble.bubbleColour {
            comboCount += 1
            pointsEarned = Int(round(Double(bubble.points) * 1.5))
        } else {
            comboCount = 1
        }

        lastPoppedcolour = bubble.bubbleColour
        score += pointsEarned

        // Animation that shows points earned after popping bubble
        let flyUp = ScoreFlyUp(
            points: pointsEarned,
            position: bubble.position,
            isCombo: comboCount > 1
        )
        scoreFlyUps.append(flyUp)

        let flyUpId = flyUp.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.scoreFlyUps.removeAll { $0.id == flyUpId }
        }

        bubbles.remove(at: index)
    }

    private func endGame() {
        gameTimer?.cancel()
        moveTimer?.cancel()

        let previousBest = highScoreManager.scores
            .first(where: { $0.name.lowercased() == playerName.lowercased() })?.score ?? 0
        isNewPersonalBest = score > previousBest

        highScoreManager.saveScore(name: playerName, score: score)
        bubbles.removeAll()
        isGameOver = true
    }

    // Cancel active timers
    func cleanup() {
        gameTimer?.cancel()
        moveTimer?.cancel()
        countdownTimer?.cancel()
    }
}

