import Foundation

struct Bubble: Identifiable {
    let id = UUID()
    let bubbleColour: BubbleColour
    var position: CGPoint
    var velocity: CGVector

    static let radius: CGFloat = 30

    var points: Int { bubbleColour.points }
}
