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
