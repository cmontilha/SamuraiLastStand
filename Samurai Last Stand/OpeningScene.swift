//
//  OpeningScene.swift
//  Samurai Last Stand
//
//  Created by Caio Montilha on 10/14/24.
//

import SpriteKit

class OpeningScene: SKScene {
    private var startLabel: SKLabelNode!
    private var background: SKSpriteNode!

    override func didMove(to view: SKView) {
        // Configuração do background
        background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = self.size
        background.zPosition = -1
        addChild(background)

        // Configuração do rótulo "Click to start the game!" na parte inferior da tela
        startLabel = SKLabelNode(text: "Click to start the game!")
        startLabel.fontSize = 40
        startLabel.fontColor = SKColor.white
        startLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.1)  // Posição ajustada para mais próximo da parte inferior
        addChild(startLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Transição para a cena do jogo (GameScene)
        let transition = SKTransition.fade(withDuration: 1.0)
        let gameScene = GameScene(size: self.size)
        view?.presentScene(gameScene, transition: transition)
    }
}
