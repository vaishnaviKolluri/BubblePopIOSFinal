import Combine
import Foundation

class HighScoreManager: ObservableObject {
    @Published var scores: [HighScoreEntry] = []

    private let fileName = "highscores.json"
    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
    }

    var highestScore: Int {
        scores.first?.score ?? 0
    }

    init() {
        loadScores()
    }

    func loadScores() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            scores = []
            return
        }
        do {
            let data = try Data(contentsOf: fileURL)
            scores = try JSONDecoder().decode([HighScoreEntry].self, from: data)
            scores.sort { $0.score > $1.score }
        } catch {
            scores = []
        }
    }

    func saveScore(name: String, score: Int) {
        if let idx = scores.firstIndex(where: { $0.name.lowercased() == name.lowercased() }) {
            if score > scores[idx].score {
                scores[idx] = HighScoreEntry(name: name, score: score)
            }
        } else {
            scores.append(HighScoreEntry(name: name, score: score))
        }
        scores.sort { $0.score > $1.score }
        persist()
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(scores)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            //
        }
    }
}
