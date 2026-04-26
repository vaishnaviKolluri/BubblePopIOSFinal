import Foundation

struct ScoreFlyUp: Identifiable {
    let id = UUID()
    let points: Int
    let position: CGPoint
    let isCombo: Bool
}
