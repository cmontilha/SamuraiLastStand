//
//  GameScene.swift
//  Samurai Last Stand
//
//  Created by Caio Montilha on 10/14/24.
//


import SpriteKit

class GameScene: SKScene {
    private var player: SKSpriteNode!
    private var background: SKSpriteNode!
    private var leftButton: SKSpriteNode!
    private var rightButton: SKSpriteNode!
    private var jumpButton: SKSpriteNode!
    private var isJumping: Bool = false
    private var zombies: [SKSpriteNode] = []
    private var skeletons: [SKSpriteNode] = [] // Array for skeletons
    private var livesLabel: SKLabelNode!
    private var scoreLabel: SKLabelNode!
    private var lives: Int = 3 {
        didSet {
            livesLabel.text = "Lives: \(lives)"
        }
    }
    private var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    override func didMove(to view: SKView) {
        // Adding the background
        background = SKSpriteNode(imageNamed: "backgroundsecond")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = CGSize(width: size.width, height: size.height)
        background.zPosition = -1
        addChild(background)

        // Adding the Samurai (Player) near the ground
        player = SKSpriteNode(imageNamed: "2D_SM02_Idle_000")
        player.position = CGPoint(x: size.width * 0.2, y: size.height * 0.2)
        player.size = CGSize(width: 100, height: 100)
        player.name = "player"
        addChild(player)

        // Start the idle animation for the samurai
        startIdleAnimation()

        // Adding control buttons
        addControlButtons()

        // Setup lives and score labels
        setupUI()

        // Start spawning zombies and skeletons
        spawnZombies()
        spawnSkeletons() // Start spawning skeletons
    }

    // Function to create and run the idle animation
    func startIdleAnimation() {
        let idleTextures = (0..<8).map { SKTexture(imageNamed: "2D_SM02_Idle_00\($0)") }
        let idleAction = SKAction.repeatForever(SKAction.animate(with: idleTextures, timePerFrame: 0.1))
        player.run(idleAction, withKey: "idle")
    }

    // Function to add control buttons
    func addControlButtons() {
        let buttonYOffset: CGFloat = 30

        // Left button with image
        leftButton = SKSpriteNode(imageNamed: "leftArrow")
        leftButton.size = CGSize(width: 80, height: 80)
        leftButton.position = CGPoint(x: leftButton.size.width, y: leftButton.size.height - buttonYOffset)
        leftButton.name = "leftButton"
        addChild(leftButton)

        // Right button with image
        rightButton = SKSpriteNode(imageNamed: "rightArrow")
        rightButton.size = CGSize(width: 80, height: 80)
        rightButton.position = CGPoint(x: size.width - rightButton.size.width, y: rightButton.size.height - buttonYOffset)
        rightButton.name = "rightButton"
        addChild(rightButton)

        // Jump button with image
        jumpButton = SKSpriteNode(imageNamed: "jump")
        jumpButton.size = CGSize(width: 100, height: 100)
        jumpButton.position = CGPoint(x: size.width / 2, y: jumpButton.size.height - buttonYOffset)
        jumpButton.name = "jumpButton"
        addChild(jumpButton)
    }

    // Function to setup UI elements (lives and score labels)
    func setupUI() {
        livesLabel = SKLabelNode(fontNamed: "Arial")
        livesLabel.fontSize = 24
        livesLabel.fontColor = .white
        livesLabel.position = CGPoint(x: size.width * 0.15, y: size.height * 0.9)
        livesLabel.text = "Lives: \(lives)"
        addChild(livesLabel)

        scoreLabel = SKLabelNode(fontNamed: "Arial")
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width * 0.85, y: size.height * 0.9)
        scoreLabel.text = "Score: \(score)"
        addChild(scoreLabel)
    }

    // Handling touches for buttons and enemies
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            let touchedNode = self.atPoint(touchLocation)

            // Check if left button is pressed
            if touchedNode.name == "leftButton" {
                movePlayer(direction: .left)
            }

            // Check if right button is pressed
            if touchedNode.name == "rightButton" {
                movePlayer(direction: .right)
            }

            // Check if jump button is pressed
            if touchedNode.name == "jumpButton" {
                if !isJumping {
                    jumpPlayer()
                }
            }

            // Check if a zombie was touched
            if touchedNode.name == "zombie" {
                killZombie(zombie: touchedNode as! SKSpriteNode)
            }
            
            // Check if a skeleton was touched
            if touchedNode.name == "skeleton" {
                killSkeleton(skeleton: touchedNode as! SKSpriteNode)
            }
        }
    }

    // Enum to manage direction
    enum Direction {
        case left, right
    }

    // Function to move the player
    func movePlayer(direction: Direction) {
        let moveDistance: CGFloat = 50.0
        var newPosition: CGPoint

        switch direction {
        case .left:
            newPosition = CGPoint(x: player.position.x - moveDistance, y: player.position.y)
        case .right:
            newPosition = CGPoint(x: player.position.x + moveDistance, y: player.position.y)
        }

        // If player leaves the screen on the left, reappear on the right and vice versa
        if newPosition.x < 0 {
            newPosition.x = size.width
        } else if newPosition.x > size.width {
            newPosition.x = 0
        }

        // Perform the movement
        player.run(SKAction.move(to: newPosition, duration: 0.2))
    }

    // Function to make the player jump
    func jumpPlayer() {
        isJumping = true
        let jumpUpAction = SKAction.moveBy(x: 0, y: 100, duration: 0.3)
        let fallDownAction = SKAction.moveBy(x: 0, y: -100, duration: 0.3)
        
        // Perform the jump sequence
        let jumpSequence = SKAction.sequence([jumpUpAction, fallDownAction])
        
        player.run(jumpSequence) {
            self.isJumping = false  // Allow jumping again after action completes
        }
    }

    // Function to spawn zombies
    func spawnZombies() {
        let spawnAction = SKAction.run {
            self.createZombie()
        }
        let delayAction = SKAction.wait(forDuration: 3.0)
        let spawnSequence = SKAction.sequence([spawnAction, delayAction])
        let repeatSpawn = SKAction.repeatForever(spawnSequence)
        run(repeatSpawn)
    }

    // Function to spawn skeletons
    func spawnSkeletons() {
        let spawnAction = SKAction.run {
            self.createSkeleton()
        }
        let delayAction = SKAction.wait(forDuration: 5.0)
        let spawnSequence = SKAction.sequence([spawnAction, delayAction])
        let repeatSpawn = SKAction.repeatForever(spawnSequence)
        run(repeatSpawn)
    }

    // Function to create a zombie and move it toward the samurai
    func createZombie() {
        let zombie = SKSpriteNode(imageNamed: "zombie")
        zombie.position = CGPoint(x: size.width, y: size.height * 0.2)
        zombie.size = CGSize(width: 60, height: 60)
        zombie.name = "zombie"
        addChild(zombie)
        zombies.append(zombie)

        // Move the zombie toward the player
        let moveAction = SKAction.move(to: player.position, duration: 10.0)
        let hitAction = SKAction.run {
            self.hitSamurai()
        }
        let sequence = SKAction.sequence([moveAction, hitAction])
        zombie.run(sequence)
    }

    // Function to create a skeleton and move it toward the samurai
    func createSkeleton() {
        let skeleton = SKSpriteNode(imageNamed: "skeleton") // Use the idle skeleton image for the default appearance
        skeleton.position = CGPoint(x: size.width, y: size.height * 0.2)
        skeleton.size = CGSize(width: 60, height: 60)
        skeleton.name = "skeleton"
        addChild(skeleton)
        skeletons.append(skeleton)

        // Move the skeleton toward the player faster than zombies
        let moveAction = SKAction.move(to: player.position, duration: 7.0) // Faster than zombies
        let hitAction = SKAction.run {
            self.hitSamurai()
        }
        let sequence = SKAction.sequence([moveAction, hitAction])
        skeleton.run(sequence)
    }

    // Function to decrease the samurai's lives
    func hitSamurai() {
        lives -= 1
        if lives <= 0 {
            gameOver()
        }
    }

    // Function to "kill" a zombie when touched
    func killZombie(zombie: SKSpriteNode) {
        zombie.removeFromParent()
        zombies.removeAll { $0 == zombie }
        score += 1
    }
    
    // Function to "kill" a skeleton when touched
    func killSkeleton(skeleton: SKSpriteNode) {
        skeleton.removeFromParent()
        skeletons.removeAll { $0 == skeleton }
        score += 1
    }

    // Function to show the Game Over screen
    func gameOver() {
        removeAllActions()
        removeAllChildren()

        // Add the background for Game Over screen
        let backgroundGameOver = SKSpriteNode(imageNamed: "backgroundthird")
        backgroundGameOver.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundGameOver.size = CGSize(width: size.width, height: size.height)
        backgroundGameOver.zPosition = -1
        addChild(backgroundGameOver)

        // Game Over label
        let gameOverLabel = SKLabelNode(fontNamed: "Arial")
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = .red
        gameOverLabel.text = "Game Over!"
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(gameOverLabel)

        // Final Score label
        let scoreLabel = SKLabelNode(fontNamed: "Arial")
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.text = "Final Score: \(score)"
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        addChild(scoreLabel)

        // Play Again button
        let playAgainButton = SKLabelNode(fontNamed: "Arial")
        playAgainButton.fontSize = 24
        playAgainButton.fontColor = .white
        playAgainButton.text = "Play Again"
        playAgainButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 100)
        playAgainButton.name = "playAgain"
        addChild(playAgainButton)
    }

    // Handling touches for the Game Over screen to restart the game
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let nodeTouched = atPoint(location)

            if nodeTouched.name == "playAgain" {
                // Restart the game
                let newGameScene = GameScene(size: size)
                view?.presentScene(newGameScene, transition: SKTransition.fade(withDuration: 1.0))
            }
        }
    }
}

