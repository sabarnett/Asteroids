//
// -----------------------------------------
// Original project: Asteroids
// Original package: Asteroids
// Created on: 24/11/2025 by: Steven Barnett
// Web: http://www.sabarnett.co.uk
// GitHub: https://www.github.com/sabarnett
// -----------------------------------------
// Copyright © 2025 Steven Barnett. All rights reserved.
//

import SpriteKit

class DashboardNode: SKNode {

    let scoreLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    let timeLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    let fuelLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")

    override init() {
        super.init()

        setupFuelGauge()
        setupTimeLabel()
        setupScoreLabel()

        // Required if we want to accept touchesBegan
//        self.isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var fuelRemaining: Double = 100.0 {
        didSet { fuelLabel.text = "⛽️ \(fuelRemaining)%" }
    }
    var score: Int = 0 {
        didSet { scoreLabel.text = "⚛️ \(score)" }
    }
    var timeElapsed: TimeInterval = 0 {
        didSet { timeLabel.text = "⏱️ \(timeElapsed.stringFormatted())" }
    }

//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("Item Touched")
//    }

    private func setupFuelGauge() {
        fuelLabel.position = CGPoint(x: 0, y: 0)
        fuelLabel.fontSize = 22.0
        addChild(fuelLabel)
        fuelRemaining = 100.0
    }

    private func setupTimeLabel() {
        timeLabel.position = CGPoint(x: 120, y: 0)
        timeLabel.fontSize = 22.0
        addChild(timeLabel)
        timeElapsed = 0
    }

    private func setupScoreLabel() {
        scoreLabel.position = CGPoint(x: 220, y: 0)
        scoreLabel.fontSize = 22.0
        addChild(scoreLabel)
        score = 0
    }
}
