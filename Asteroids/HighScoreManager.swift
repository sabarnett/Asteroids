//
// -----------------------------------------
// Original project: Asteroids
// Original package: Asteroids
// Created on: 01/12/2025 by: Steven Barnett
// Web: http://www.sabarnett.co.uk
// GitHub: https://www.github.com/sabarnett
// -----------------------------------------
// Copyright © 2025 Steven Barnett. All rights reserved.
//

import Foundation

struct HighScore: Codable, Identifiable {
    var id: UUID = UUID()
    var score: Int
    var time: TimeInterval
}

class HighScoreManager {
    private let saveFileName = "AsteroidsHighScore"
    private var highScores: [HighScore] = []

    private(set) var scoreAdded: Bool = false

    var scores: [HighScore] {
        highScores.sorted(by: {
            if $0.score == $1.score {
                return $0.time > $1.time
            }
            return $0.score > $1.score
        })
    }

    init() {
        loadHighScores()
    }

    func add(score: Int, inTime time: TimeInterval) {
        let newScore = HighScore(score: score, time: time)
        highScores.append(newScore)

        scoreAdded = false

        // If we don't have all 5 scores yet, then this is a winner
        if highScores.count <= 5 {
            saveHighScores()
            scoreAdded = true
            return
        }

        // We must have 6 scores now, so is this new one greater
        // than the lowest existing score.
        let sortedList = highScores.sorted(by:
        {
            if $0.score == $1.score {
                return $0.time > $1.time
            }
            return $0.score > $1.score }
        )
        let lowest = sortedList.last!
        highScores.removeAll(where: {$0.id == lowest.id })

        if lowest.id != newScore.id {
            saveHighScores()
            scoreAdded = true
        }
    }

    /// Loads the high scores from the AsteroidsHighScores file in the users documents folder
    private func loadHighScores() {
        let loadFileUrl = fileUrl(file: saveFileName)

        guard let gameData = try? Data(contentsOf: loadFileUrl) else { return }
        guard let decodedData = try? JSONDecoder().decode([HighScore].self, from: gameData) else { return }

        highScores = decodedData
    }

    /// Save the leader board to a JSON file called AsteroidsHighScores in the users documents folder.
    private func saveHighScores() {
        let saveFileUrl = fileUrl(file: saveFileName)

        // Json encode and save the file
        guard let encoded = try? JSONEncoder().encode(highScores) else {
            return
        }

        try? encoded.write(to: saveFileUrl, options: .atomic)
    }

    /// Generate the file name to save the data to or to reload the data from.
    ///
    /// - Parameter gameDefinition: The definition of the game
    ///
    /// - Returns: The URL to use to save the file. It is based on the name of the
    /// game file and will be saved to the users document directory.
    private func fileUrl(file: String) -> URL {
        let fileName = file + ".save"
        return URL.documentsDirectory.appendingPathComponent(fileName)
    }
}
