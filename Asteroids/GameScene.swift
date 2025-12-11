//
// -----------------------------------------
// Original project: Asteroids
// Original package: Asteroids
// Created on: 28/10/2025 by: Steven Barnett
// Web: http://www.sabarnett.co.uk
// GitHub: https://www.github.com/sabarnett
// -----------------------------------------
// Copyright © 2025 Steven Barnett. All rights reserved.
//

import SpriteKit
import SwiftUI

@objcMembers
class GameScene: SKScene, SKPhysicsContactDelegate {

    var gameNode = SKNode()
    var popupNode = SKNode()

    var dataModel: SceneDataModel!

    let player = SKSpriteNode(imageNamed: "player-rocket.png")
    let dashboard = DashboardNode()
    let toolbar = ToolbarNode()

    let music = SKAudioNode(fileNamed: "cyborg-ninja.mp3")

    var gameTimer: Timer?
    var popup: HighScoresPopup?

    // MARK: - SpriteKit handler overrides

    override func didMove(to view: SKView) {
        addChild(gameNode)
        addChild(popupNode)

        createBackgroundImageAndMusic()
        createStarScape()
        createToolbar()
        initialiseDashboard()
        placePlayer()

        physicsWorld.contactDelegate = self

        gameTimer = Timer.scheduledTimer(timeInterval: 0.35,
                                         target: self,
                                         selector: #selector(createEnemy),
                                         userInfo: nil,
                                         repeats: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // The tappedNodes variable will create a collection of all the nodes at
        // a specific place on the screen. Given the nature of the game, there may
        // be more than one node at any given location. It is up to us to determine
        // if the node we are interested in is at this location. You might have the
        // rocket or an asteroid or an energy spot or any combination of them.
        let tappedNodes = nodes(at: location)

        if tappedNodes.contains(player) {
            dataModel.touchingPlayer = true
        } else if tappedNodes.first(where: { $0.name == "gameOver"}) != nil {
            newGame()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard dataModel.touchingPlayer else { return }
        guard let touch = touches.first else { return }

        // Move the player to the new location
        let location = touch.location(in: self)
        player.position = location
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        dataModel.touchingPlayer = false
    }

    override func update(_ currentTime: TimeInterval) {
        if dataModel.gameOver { return }
        if popup != nil { return }

        removeOffScreenNodes()
        ensurePlayerRemainsOnScreen()
    }

    // MARK: - Create asteroids and energy boosts

    func createEnemy() {
        if dataModel.gamePaused { return }

        guard useFuel() else { return }

        // Occasionally miss an asteroid - gives the impression of
        // some spacing
        if Int.random(in: 0...5) != 2 {
            let sprite = SKSpriteNode(imageNamed: "asteroid")
            sprite.position = CGPoint(x: 1200, y: Int.random(in: -350...350))
            sprite.zPosition = 1
            sprite.name = "enemy"

            let size = sprite.size
            let scale = Double.random(in: 0.6...1.1)
            let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
            sprite.scale(to: scaledSize)

            sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
            sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
            sprite.physicsBody?.linearDamping = 0
            sprite.physicsBody?.categoryBitMask = 0
            sprite.physicsBody?.contactTestBitMask = 1

            sprite.run(.sequence([
                .repeatForever(
                    .rotate(byAngle: -3.14159 * 2.0, duration: 3.0)
                )
            ]))

            gameNode.addChild(sprite)

            dashboard.timeElapsed += 0.35
        }

        // Create energy to collect - 1 time in 3 so it's not too easy
        if Int.random(in: 0...2) == 1 {
            createBonus()
        }
    }

    func createBonus() {
        let sprite = SKSpriteNode(imageNamed: "atom")

        // Attempt to generate a position for the energy that is not on top of
        // an existing asteroid. We try 5 times before we give up and accept
        // the position we get.
        for _ in 0..<5 {
            sprite.position = CGPoint(x: 1200, y: Int.random(in: -350...350))
            if nodes(at: sprite.position).first(where: { $0.name == "enemy" }) == nil {
                break
            }
        }

        sprite.zPosition = 1
        sprite.name = "bonus"
        sprite.size = CGSize(width: 48, height: 48)

        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.categoryBitMask = 0
        sprite.physicsBody?.contactTestBitMask = 1
        sprite.physicsBody?.collisionBitMask = 0

        sprite.run(.sequence([
            .repeatForever(
                .rotate(byAngle: 3.14159 * 2.0, duration: 1.5)
            )
        ]))

        gameNode.addChild(sprite)
    }

    // MARK: - Handle collisions

    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        if nodeA == player {
            playerHit(nodeB)
        } else {
            playerHit(nodeA)
        }
    }

    func playerHit(_ node: SKNode) {
        if bonusHit(node: node) { return }

        if let particles = SKEmitterNode(fileNamed: "Explosion") {
            particles.position = node.position
            particles.zPosition = 3
            gameNode.addChild(particles)
        }
        showGameOver()
    }

    func bonusHit(node: SKNode) -> Bool {
        if node.name != "bonus" { return false }

        node.removeFromParent()

        if dataModel.playingSound {
            let sound = SKAction.playSoundFileNamed("bonus.wav", waitForCompletion: false)
            run(sound)
        }

        dashboard.fuelRemaining = min(dashboard.fuelRemaining + 10, 100)
        dashboard.score += 1

        return true
    }

    // MARK: - Game over and game restart

    func showGameOver() {
        if dataModel.gameOver { return }

        dataModel.gameOver = true
        gameTimer?.invalidate()

        if dataModel.playingSound {
            let sound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
            run(sound)
        }

        let gameOverPopup = SKSpriteNode(imageNamed: "gameOver-2")
        gameOverPopup.zPosition = 10
        gameOverPopup.name = "gameOver"
        gameNode.addChild(gameOverPopup)

        let playAgain = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
        playAgain.text = "Tap to play again"
        playAgain.position = CGPoint(x: gameOverPopup.position.x, y: gameOverPopup.position.y - 120)
        playAgain.zPosition = 10
        playAgain.name = "gameOver"
        gameNode.addChild(playAgain)

        music.removeFromParent()
        player.removeFromParent()

        dataModel.highScores.add(score: dashboard.score, inTime: dashboard.timeElapsed)
        if dataModel.highScores.scoreAdded {
            popup = HighScoresPopup(scores: dataModel.highScores, latestScore: dashboard.score) {
                // It closed!
                self.popup = nil
            }
            popup!.position = CGPoint(x: 0, y: 0)
            popup!.zPosition = 9999

            popupNode.addChild(popup!)
            popup!.show()
        }
    }

    private func newGame() {
        if let scene = GameScene(fileNamed: "GameScene") {
            dataModel.resetState()
            scene.dataModel = dataModel
            scene.scaleMode = .aspectFill
            self.view?.presentScene(scene)
        }
    }

    // MARK: - Game play helpers

    private func removeOffScreenNodes() {
        for node in children {
            if node.position.x < -700 {
                node.removeFromParent()
            }
        }
    }

    private func ensurePlayerRemainsOnScreen() {
        if player.position.x < -400 { player.position.x = -400 }
        if player.position.x > 400 { player.position.x = 400 }
        if player.position.y < -300 { player.position.y = -300 }
        if player.position.y > 300 { player.position.y = 300 }
    }

    private func useFuel() -> Bool {
        dashboard.fuelRemaining -= 2

        if dashboard.fuelRemaining <= 0.0 {
            showGameOver()
            return false
        }

        return true
    }

    // MARK: - Initialisation

    private func createBackgroundImageAndMusic() {
        let background = SKSpriteNode(imageNamed: "space.jpg")
        background.zPosition = -1
        gameNode.addChild(background)

        music.name = "music"
        if dataModel.playingSound {
            addChild(music)
        }
    }

    private func createStarScape() {
        // Create the effect of moving through space with randomly created
        // 'stars' moving past the craft.
        if let particles = SKEmitterNode(fileNamed: "SpaceDust") {
            particles.advanceSimulationTime(10)
            particles.position.x = 512
            gameNode.addChild(particles)
        }
    }

    private func createToolbar() {
        toolbar.delegate = self
        toolbar.dataModel = self.dataModel
        toolbar.position = CGPoint(x: 390, y: 310)
        gameNode.addChild(toolbar)
    }

    private func initialiseDashboard() {
        dashboard.position = CGPoint(x: -490, y: 300)
        dashboard.zPosition = 2
        gameNode.addChild(dashboard)
    }

    private func placePlayer() {
        player.position.x = -400
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.categoryBitMask = 1
        gameNode.addChild(player)
    }
}

// MARK: - Toolbar handling

extension GameScene: ToolbarDelegate {
    func showLeaderBoard() {
        let wasPaused = dataModel.gamePaused

        // Pause the game if it isn't already paused.
        if !wasPaused {
            playPause(isPaused: true)
        }

        popup = HighScoresPopup(scores: dataModel.highScores, latestScore: dashboard.score) {
            // OnClose - toggle the game back on
            if !wasPaused {
                self.playPause(isPaused: false)
            }
            self.popup = nil
        }
        popup!.position = CGPoint(x: 0, y: 0)
        popup!.zPosition = 9999

        popupNode.addChild(popup!)
        popup!.show()
    }

    func playPause(isPaused: Bool) {
        if isPaused  == false {
            dataModel.gamePaused = false
            gameNode.isPaused = false
            gameNode.speed = 1
            self.physicsWorld.speed = 1

            if dataModel.playingSound == false {
                addChild(music)
                dataModel.playingSound = true
            }
        } else {
            dataModel.gamePaused = true
            gameNode.isPaused = true
            gameNode.speed = 0
            self.physicsWorld.speed = 0

            if dataModel.playingSound {
                music.removeFromParent()
                dataModel.playingSound = false
            }
        }
    }

    func playSound(turnOn: Bool) {
        if turnOn {
            addChild(music)
            dataModel.playingSound = true
        } else {
            music.removeFromParent()
            dataModel.playingSound = false
        }
    }
}
