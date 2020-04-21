//
//  Menu.swift
//  basketball
//
//  Created by Prism Student on 2020-04-21.
//  Copyright © 2020 Edmund Lui. All rights reserved.
//

import SpriteKit
import GameplayKit

class Menu: SKScene {
    
    var playButton : SKLabelNode?
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.white
        
        let playButton = SKLabelNode(fontNamed: "PartyLetPlain")
        playButton.fontColor = SKColor.black
        playButton.fontSize = 100
        playButton.name="playButton"
        playButton.text = "PLAY"
        playButton.position =  CGPoint(x:self.frame.midX, y:self.frame.midY);
        self.addChild(playButton)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch: AnyObject in touches {
        let location = touch.location(in: self)
        let theNode = self.atPoint(location)
        if theNode.name == "playButton" {
            print("play button pressed")
            let transition = SKTransition.moveIn(with: SKTransitionDirection.left, duration: 2)
            let gameScene = GameScene2(size: self.size)
            self.view?.presentScene(gameScene, transition: transition)
            }
        }
    }

}
