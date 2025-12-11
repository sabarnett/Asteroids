//
// -----------------------------------------
// Original project: Asteroids
// Original package: Asteroids
// Created on: 11/12/2025 by: Steven Barnett
// Web: http://www.sabarnett.co.uk
// GitHub: https://www.github.com/sabarnett
// -----------------------------------------
// Copyright © 2025 Steven Barnett. All rights reserved.
//

import SpriteKit

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
