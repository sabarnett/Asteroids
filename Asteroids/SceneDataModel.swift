//
// -----------------------------------------
// Original project: Asteroids
// Original package: Asteroids
// Created on: 29/10/2025 by: Steven Barnett
// Web: http://www.sabarnett.co.uk
// GitHub: https://www.github.com/sabarnett
// -----------------------------------------
// Copyright © 2025 Steven Barnett. All rights reserved.
//

import Combine
import Foundation

final class SceneDataModel: ObservableObject {

    @Published var highScores = HighScoreManager()

    @Published var gameOver = false
    @Published var gamePaused: Bool = false
    @Published var touchingPlayer = false
    @Published var playingSound = true

    func resetState() {
        gameOver = false
        gamePaused = false
        touchingPlayer = false

        // Items we do not reset between games...
//        playingSound = true
    }
}
