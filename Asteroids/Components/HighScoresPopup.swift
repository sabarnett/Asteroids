//
// -----------------------------------------
// Original project: Asteroids
// Original package: Asteroids
// Created on: 29/11/2025 by: Steven Barnett
// Web: http://www.sabarnett.co.uk
// GitHub: https://www.github.com/sabarnett
// -----------------------------------------
// Copyright © 2025 Steven Barnett. All rights reserved.
//

import SpriteKit

class HighScoresPopup: SKNode {

    var onClose: () -> Void

    private let background: SKSpriteNode
    private let panel: SKSpriteNode
    private let closeButton: SKSpriteNode

    private let panelSize = CGSize(width: 620, height: 580)

    init(scores: [HighScore], latestScore: Int, onClose: @escaping () -> Void) {
        self.onClose = onClose

        // Dim background
        background = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.55),
                                  size: CGSize(width: 4000, height: 4000))
        background.zPosition = 0
        
        // Panel window
        panel = SKSpriteNode(imageNamed: "highScores")
        panel.zPosition = 1
        panel.setScale(0.01) // start small for animation
        
        // Close button
        closeButton = SKSpriteNode(imageNamed: "closeButton")
        closeButton.name = "closeButton"
        closeButton.position = CGPoint(x: panelSize.width/2 - 45,
                                       y: panelSize.height/2 - 55)
        closeButton.zPosition = 2

        super.init()
        
        isUserInteractionEnabled = true

        addChild(background)
        addChild(panel)
        panel.addChild(closeButton)

        // Build UI
        createScoreList(scores, latestScore: latestScore)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI Construction

    private func createScoreList(_ scores: [HighScore], latestScore: Int) {
        var latestShown = false
        var fontSize = 32.0
        let startY: CGFloat = panelSize.height/2 - 200
        let spacing: CGFloat = 60
        
        for (i, score) in scores.enumerated() {
            if score.score == latestScore && latestShown == false {
                latestShown = true
                fontSize = 38
            } else {
                fontSize = 30
            }
            let label = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
            label.fontSize = fontSize
            label.fontColor = .black
            label.horizontalAlignmentMode = .left

            label.text = "Score: \(score.score) in \(score.time.minutes()) mins and \(score.time.seconds()) secs"

            label.position = CGPoint(x: -panelSize.width/2 + 70,
                                     y: startY - CGFloat(i) * spacing)

            panel.addChild(label)
        }
    }

    // MARK: - Animations

    func show() {
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        background.run(fadeIn)

        let scaleUp = SKAction.scale(to: 1.0, duration: 0.28)
        scaleUp.timingMode = .easeOut

        panel.run(scaleUp)
    }

    func hide(completion: @escaping () -> Void = {}) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        background.run(fadeOut)

        let scaleDown = SKAction.scale(to: 0.01, duration: 0.22)
        scaleDown.timingMode = .easeIn
        
        panel.run(scaleDown) {
            completion()
            self.onClose()
        }
    }

    // MARK: - Touch Handling (Self-contained)

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: panel)
        let node = panel.atPoint(location)

        if node.name == "closeButton" {
            hide()
        }
    }
}
