//
// -----------------------------------------
// Original project: Asteroids
// Original package: Asteroids
// Created on: 08/12/2025 by: Steven Barnett
// Web: http://www.sabarnett.co.uk
// GitHub: https://www.github.com/sabarnett
// -----------------------------------------
// Copyright © 2025 Steven Barnett. All rights reserved.
//

import SpriteKit

protocol ToolbarDelegate {
    func playPause(isPaused: Bool)
    func playSound(turnOn: Bool)
    func showLeaderBoard()
}

class ToolbarNode: SKNode {

    var delegate: ToolbarDelegate?

    let playPause = SKSpriteNode(imageNamed: "pauseButton")
    let playSound = SKSpriteNode(imageNamed: "soundOff")
    let leaderBoard = SKSpriteNode(imageNamed: "leaderBoard")

    override init() {
        super.init()

        leaderBoard.position = CGPoint(x: 0, y: 0)
        leaderBoard.name = "LeaderBoard"
        addChild(leaderBoard)

        playPause.position = CGPoint(x: 55, y: 0)
        playPause.name = "PlayPause"
        addChild(playPause)

        playSound.position = CGPoint(x: 110, y: 0)
        playSound.name = "PlaySound"
        addChild(playSound)

        self.isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        let tappedNodes = nodes(at: location)
        if let _ = tappedNodes.first(where: {$0.name == "PlayPause"}) {
            togglePlayPause()

        } else if let _ = tappedNodes.first(where: {$0.name == "LeaderBoard"} ) {
            // showLeader Board tapped
            delegate?.showLeaderBoard()

        } else if let _ = tappedNodes.first(where: { $0.name == "PlaySound"}) {
            // Play/pause sound tapped
            togglePlayMusic()
        }
    }

    func togglePlayMusic() {
        // The music node is in the paremnt of the game node. We are a
        // child of the game node, so we need to go up two levels to
        // detect the music node.
        guard let parentNode = parent?.parent else {
            return
        }

        if parentNode.children.first(where: {$0.name == "music"}) != nil {
            // Turn music off
            playSound.texture = SKTexture(imageNamed: "soundOn")
            delegate?.playSound(turnOn: false)
        } else {
            // turn nusic on
            playSound.texture = SKTexture(imageNamed: "soundOff")
            delegate?.playSound(turnOn: true)
        }
    }

    func togglePlayPause() {
        guard let parent else { return }

        if parent.isPaused {
            playPause.texture = SKTexture(imageNamed: "pauseButton")
            parent.isPaused = false
            delegate?.playPause(isPaused: false)
        } else {
            playPause.texture = SKTexture(imageNamed: "playButton")
            parent.isPaused = true
            delegate?.playPause(isPaused: true)
        }

    }
}
