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

    private let background: SKSpriteNode
    private let panel: SKSpriteNode
    private let closeButton: SKSpriteNode

    private let panelSize = CGSize(width: 620, height: 580)

    var onHide: () -> Void

    init(scores: [Int], onHide: @escaping () -> Void = {}) {
        self.onHide = onHide

        // Dim background
        background = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.55),
                                  size: CGSize(width: 4000, height: 4000))
        background.zPosition = 0
        
        // Panel window
        panel = SKSpriteNode(color: UIColor.white, size: panelSize)
        panel.zPosition = 1
        panel.setScale(0.01) // start small for animation
        
        // Close button
        closeButton = SKSpriteNode(imageNamed: "close")
        closeButton.name = "closeButton"
        closeButton.position = CGPoint(x: panelSize.width/2 - 35,
                                       y: panelSize.height/2 - 35)
        closeButton.zPosition = 2

        super.init()
        
        isUserInteractionEnabled = true

        addChild(background)
        addChild(panel)
        panel.addChild(closeButton)

        // Build UI
        createTitle()
        createScoreList(scores)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI Construction

    private func createTitle() {
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = "High Scores"
        label.fontSize = 44
        label.fontColor = .black
        label.position = CGPoint(x: 0, y: panelSize.height/2 - 90)
        panel.addChild(label)
    }

    private func createScoreList(_ scores: [Int]) {
        let startY: CGFloat = panelSize.height/2 - 150
        let spacing: CGFloat = 40
        
        for (i, score) in scores.enumerated() {
            let label = SKLabelNode(fontNamed: "Helvetica")
            label.fontSize = 32
            label.fontColor = .darkGray
            label.horizontalAlignmentMode = .left

            label.text = "\(i+1).  \(score)"
            
            label.position = CGPoint(x: -panelSize.width/2 + 40,
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
        }
    }

    // MARK: - Touch Handling (Self-contained)

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: panel)
        let node = panel.atPoint(location)

        if node.name == "closeButton" {
            hide()
            onHide()
        }
    }
}
