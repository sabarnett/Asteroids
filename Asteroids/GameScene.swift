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

    var dataModel: SceneDataModel!

    let playPause = SKSpriteNode(imageNamed: "pauseButton")
    let playSound = SKSpriteNode(imageNamed: "soundOffButton")

    let player = SKSpriteNode(imageNamed: "player-rocket.png")
    let dashboard = DashboardNode()

    let music = SKAudioNode(fileNamed: "cyborg-ninja.mp3")

    var gameOver = false
    var touchingPlayer = false
    var gameTimer: Timer?
    var gameLoaded = false

    override func didMove(to view: SKView) {
        createBackgroundImageAndMusic()
        createStarScape()
        placePlayer()

        playPause.position = CGPoint(x: 480, y: 320)
        playPause.name = "PlayPause"
        addChild(playPause)

        playSound.position = CGPoint(x: 420, y: 320)
        playSound.name = "PlaySound"
        addChild(playSound)

        physicsWorld.contactDelegate = self

        dashboard.position = CGPoint(x: -490, y: 300)
        dashboard.zPosition = 2
        addChild(dashboard)

        gameTimer = Timer.scheduledTimer(timeInterval: 0.35,
                                         target: self,
                                         selector: #selector(createEnemy),
                                         userInfo: nil,
                                         repeats: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // what nodes are at the location (background, possibly particles,
        // possibly the player, possibly energy) We only want the player.
        let tappedNodes = nodes(at: location)
        if tappedNodes.contains(player) {
            touchingPlayer = true
        } else if let _ = tappedNodes.first(where: { $0.name == "gameOver"}) {
            newGame()
        } else if let ppNode = tappedNodes.first(where: {$0.name == "PlayPause"}) {
            isPaused.toggle()

            let ppNode2 = ppNode as! SKSpriteNode
            ppNode2.texture = isPaused
                ? SKTexture(imageNamed: "playButton")
                : SKTexture(imageNamed: "pauseButton")
        } else if let muNode = tappedNodes.first(where: { $0.name == "PlaySound"}) {
            let muNode2 = muNode as! SKSpriteNode
            if music.parent == nil {
                addChild(music)
                muNode2.texture = SKTexture(imageNamed: "soundOffButton")
            } else {
                music.removeFromParent()
                muNode2.texture = SKTexture(imageNamed: "soundOnButton")
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touchingPlayer else { return }
        guard let touch = touches.first else { return }

        // Move the player to the new location
        let location = touch.location(in: self)
        player.position = location
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user stops touching the screen
        touchingPlayer = false
    }

    override func update(_ currentTime: TimeInterval) {
        // this method is called before each frame is rendered
        if gameOver { return }

        for node in children {
            if node.position.x < -700 {
                node.removeFromParent()
            }
        }

        if player.position.x < -400 { player.position.x = -400 }
        if player.position.x > 400 { player.position.x = 400 }
        if player.position.y < -300 { player.position.y = -300 }
        if player.position.y > 300 { player.position.y = 300 }
    }

    func createEnemy() {
        if isPaused { return }

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

            addChild(sprite)

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

        addChild(sprite)
    }

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
        if node.name == "bonus" {
            node.removeFromParent()

            let sound = SKAction.playSoundFileNamed("bonus.wav", waitForCompletion: false)
            run(sound)

            dashboard.fuelRemaining = min(dashboard.fuelRemaining + 10, 100)
            dashboard.score += 1

            return
        }


        if let particles = SKEmitterNode(fileNamed: "Explosion") {
            particles.position = node.position
            particles.zPosition = 3
            addChild(particles)
        }
        showGameOver()
    }

    func showGameOver() {
        let sound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
        run(sound)

        let gameOver = SKSpriteNode(imageNamed: "gameOver-2")
        gameOver.zPosition = 10
        gameOver.name = "gameOver"
        addChild(gameOver)

        let playAgain = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
        playAgain.text = "Tap to play again"
        playAgain.position = CGPoint(x: gameOver.position.x, y: gameOver.position.y - 120)
        playAgain.zPosition = 10
        playAgain.name = "gameOver"
        addChild(playAgain)

        music.removeFromParent()
        player.removeFromParent()

        self.gameOver = true
        gameTimer?.invalidate()
    }

    private func useFuel() -> Bool {
        dashboard.fuelRemaining -= 2

        if dashboard.fuelRemaining <= 0.0 {
            showGameOver()
            return false
        }

        return true
    }

    private func createBackgroundImageAndMusic() {
        let background = SKSpriteNode(imageNamed: "space.jpg")
        background.zPosition = -1
        addChild(background)

        addChild(music)
    }

    private func createStarScape() {
        // Create the effect of moving through space with randomly created
        // 'stars' moving past the craft.
        if let particles = SKEmitterNode(fileNamed: "SpaceDust") {
            particles.advanceSimulationTime(10)
            particles.position.x = 512
            addChild(particles)
        }
    }

    private func placePlayer() {
        player.position.x = -400
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.categoryBitMask = 1
        addChild(player)
    }

    private func newGame() {
        if let scene = GameScene(fileNamed: "GameScene") {
            scene.dataModel = dataModel
            scene.scaleMode = .aspectFill
            self.view?.presentScene(scene)
        }
    }
}
