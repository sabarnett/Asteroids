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

    private enum NodeNames: String {

        case scoreLabel, closeButton, resetScores

        var name: String {
            switch self {
            case .scoreLabel: return "ScoreLabel"
            case .closeButton: return "CloseButton"
            case .resetScores: return "ResetScores"
            }
        }
    }

    /// Called when the popup window is closed. This is used by the caller to reset the environment
    var onClose: () -> Void
    var highScoreManager: HighScoreManager

    /// The label where the high scores will be displayed. It is a simple graphic
    /// with a pre-formatted title.
    private var panel: SKSpriteNode!

    private var background: SKSpriteNode!

    /// Matches the dize of the high scores panel. We use this to correctly position
    /// anything  that we place on the panel.
    private let panelSize = CGSize(width: 620, height: 580)

    init(scores: HighScoreManager, latestScore: Int, onClose: @escaping () -> Void) {
        self.onClose = onClose
        self.highScoreManager = scores

        super.init()
        isUserInteractionEnabled = true

        createBackground()
        createHighScoresPanel()
        createCloseButton()
        createResetButton()
        createScoreList(scores.scores, latestScore: latestScore)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - High Scores list

    /// Creates the list of scores, ordered by the score. If there are multiple scores with the
    /// same value, we order them by the amount of time the player survived to achieve that
    /// score (longest to shortest). The most recently added score, if known, is highlighted.
    ///
    /// - Parameters:
    ///   - scores: The list of the five highest scores
    ///   - latestScore: The last score added which we can use to highlight it.
    private func createScoreList(_ scores: [HighScore], latestScore: Int) {
        var latestShown = false
        var isLatest = false
        let startY: CGFloat = panelSize.height/2 - 200
        let spacing: CGFloat = 45

        let titles = ScoreTitleNode()
        titles.position = CGPoint(x: (-panelSize.width/2) + 120, y: startY)
        panel.addChild(titles)

        for (i, score) in scores.enumerated() {
            if score.score == latestScore && latestShown == false {
                latestShown = true
                isLatest = true
            } else {
                isLatest = false
            }
            let label = ScoreNode(score: score, isLatest: isLatest)

            label.position = CGPoint(x: (-panelSize.width/2) + 140,
                                     y: startY - CGFloat(i + 1) * spacing)

            label.name = NodeNames.scoreLabel.name
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

        if node.name == NodeNames.closeButton.name {
            hide()
        }

        if node.name == NodeNames.resetScores.name {
            highScoreManager.reset()
            for label in panel.children {
                if label.name == NodeNames.scoreLabel.name {
                    label.removeFromParent()
                }
            }
        }
    }

    /// A background node that covers the entire screen and greys out the
    /// currently active game board.
    private func createBackground() {
        background = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.55),
                                  size: CGSize(width: 4000, height: 4000))
        background.zPosition = 0
        addChild(background)
    }

    private func createHighScoresPanel() {
        panel = SKSpriteNode(imageNamed: "highScores")
        panel.zPosition = 1
        panel.setScale(0.01) // start small for animation
        addChild(panel)
    }

    private func createCloseButton() {
        let closeButton = SKSpriteNode(imageNamed: "closeButton")
        closeButton.name = NodeNames.closeButton.name
        closeButton.position = CGPoint(x: panelSize.width/2 - 45,
                                       y: panelSize.height/2 - 55)
        closeButton.zPosition = 2
        panel.addChild(closeButton)
    }

    private func createResetButton() {
        let reset = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
        reset.text = "Reset high scores"
        reset.fontSize = 24
        reset.fontColor = .darkGray
        reset.name = NodeNames.resetScores.name
        reset.position = CGPoint(x: 0,
                                 y: (-panelSize.height / 2) + 50)
        panel.addChild(reset)
    }
}

class ScoreNode: SKNode {

    var scoreLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    var minuteLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    var secondLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")

    init(score: HighScore, isLatest: Bool = false) {
        super.init()

        if isLatest {
            let bgNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 332, height: 40))
            bgNode.fillColor = .orange
            addChild(bgNode)
        }

        scoreLabel.fontSize = 30
        scoreLabel.fontColor = .black
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 10, y: 10)
        scoreLabel.text = score.score.formatted(.number.precision(.integerLength(0...4)))
        addChild(scoreLabel)

        minuteLabel.fontSize = 30
        minuteLabel.fontColor = .black
        minuteLabel.horizontalAlignmentMode = .left
        minuteLabel.position = CGPoint(x: 210, y: 10)
        minuteLabel.text = score.time.minutes()
        addChild(minuteLabel)

        secondLabel.fontSize = 30
        secondLabel.fontColor = .black
        secondLabel.horizontalAlignmentMode = .left
        secondLabel.position = CGPoint(x: 290, y: 10)
        secondLabel.text = score.time.seconds()
        addChild(secondLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ScoreTitleNode: SKNode {

    var scoreLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    var minuteLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    var secondLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")

    override init() {
        super.init()

        scoreLabel.fontSize = 32
        scoreLabel.fontColor = .black
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 10, y: 10)
        scoreLabel.text = "Score"
        addChild(scoreLabel)

        minuteLabel.fontSize = 32
        minuteLabel.fontColor = .black
        minuteLabel.horizontalAlignmentMode = .left
        minuteLabel.position = CGPoint(x: 220, y: 10)
        minuteLabel.text = "Mins"
        addChild(minuteLabel)

        secondLabel.fontSize = 32
        secondLabel.fontColor = .black
        secondLabel.horizontalAlignmentMode = .left
        secondLabel.position = CGPoint(x: 300, y: 10)
        secondLabel.text = "Secs"
        addChild(secondLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
