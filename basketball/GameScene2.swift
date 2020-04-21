//
//  GameScene2.swift
//  basketball
//
//  Created by Prism Student on 2020-04-21.
//  Copyright © 2020 Edmund Lui. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene2: SKScene, SKPhysicsContactDelegate {

    //Start and end points for when ball is thrown
    var start = CGPoint()
    var end = CGPoint()
    
    //Counter for points
    var points = 0
    
    //Constants that I will need to throw the ball
    var grav = CGFloat()
    var yVel = CGFloat()
    var airTime = TimeInterval()
    var pi = CGFloat(Double.pi)

    var grids = false   // turn on to see all the physics grid lines
    
    var bg = SKSpriteNode(imageNamed: "bgImage")
    var rim = SKSpriteNode(imageNamed: "rim")
    var backboard = SKSpriteNode(imageNamed: "backboard")
    var basketball = SKSpriteNode(imageNamed: "basketball")

    //objects in the scene
    var ball = SKShapeNode()
    var leftWall = SKShapeNode()
    var rightWall = SKShapeNode()
    var endG = SKShapeNode()
    var startG = SKShapeNode()
    var pointsLabel = SKLabelNode()
    var countdownLabel = SKLabelNode()

    var touchingBall = false

    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self

        grav = -4
        yVel = self.frame.height
        airTime = 1.5

        physicsWorld.gravity = CGVector(dx: 0, dy: grav)

        setUpGame()
    }

    // Fires the instant a touch has made contact with the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        
        for touch in touches {
            let location = touch.location(in: self)
            if GameState.current == .playing {
                if ball.contains(location){
                    start = location
                    touchingBall = true
                }
            }
        }
    }

    // Fires as soon as the touch leaves the screen
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if GameState.current == .playing && !ball.contains(location) && touchingBall{
                end = location
                touchingBall = false
                throwBall()
            }
        }
    }

    // Set the images and physics properties of the GameScene
    func setUpGame() {
        GameState.current = .playing

        // Background
        let bgScale = CGFloat(bg.frame.width / bg.frame.height)

        bg.size.height = self.frame.height
        bg.size.width = bg.size.height * bgScale
        bg.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        bg.zPosition = 0
        self.addChild(bg)

        //Setting up initial net position
        let binScale = CGFloat(backboard.frame.width / backboard.frame.height)

        backboard.size.height = self.frame.height / 5
        backboard.size.width = backboard.size.height * binScale
        backboard.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 1.5)
        backboard.zPosition = bg.zPosition + 1
        self.addChild(backboard)

        rim.size = backboard.size
        rim.position = backboard.position
        rim.zPosition = backboard.zPosition + 3
        self.addChild(rim)

        // Start ground
        startG = SKShapeNode(rectOf: CGSize(width: self.frame.width, height: 5))
        startG.fillColor = .red
        startG.strokeColor = .clear
        startG.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 10)
        startG.zPosition = 10
        startG.alpha = grids ? 1 : 0

        startG.physicsBody = SKPhysicsBody(rectangleOf: startG.frame.size)
        startG.physicsBody?.categoryBitMask = PhysicsCatory.ballGround
        startG.physicsBody?.collisionBitMask = PhysicsCatory.ball
        startG.physicsBody?.contactTestBitMask = PhysicsCatory.none
        startG.physicsBody?.affectedByGravity = false
        startG.physicsBody?.isDynamic = false
        self.addChild(startG)

        // End ground
        endG = SKShapeNode(rectOf: CGSize(width: self.frame.width * 2, height: 5))
        endG.fillColor = .red
        endG.strokeColor = .clear
        endG.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2.5)
        endG.zPosition = 10
        endG.alpha = grids ? 1 : 0
        
        endG.physicsBody = SKPhysicsBody(rectangleOf: endG.frame.size)
        endG.physicsBody?.categoryBitMask = PhysicsCatory.netGround
        endG.physicsBody?.collisionBitMask = PhysicsCatory.ball
        endG.physicsBody?.contactTestBitMask = PhysicsCatory.none
        endG.physicsBody?.affectedByGravity = false
        endG.physicsBody?.isDynamic = false
        self.addChild(endG)

        // borders for the net
        leftWall = SKShapeNode(rectOf: CGSize(width: 3, height: rim.frame.height / 2.5))
        leftWall.fillColor = .red
        leftWall.strokeColor = .clear
        leftWall.position = CGPoint(x: rim.position.x - 28, y: rim.position.y-43)
        leftWall.zPosition = 10
        leftWall.alpha = grids ? 1 : 0

        leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.frame.size)
        leftWall.physicsBody?.categoryBitMask = PhysicsCatory.leftBarrier
        leftWall.physicsBody?.collisionBitMask = PhysicsCatory.ball
        leftWall.physicsBody?.contactTestBitMask = PhysicsCatory.none
        leftWall.physicsBody?.affectedByGravity = false
        leftWall.physicsBody?.isDynamic = false
        self.addChild(leftWall)

        // Right wall of the bin
        rightWall = SKShapeNode(rectOf: CGSize(width: 3, height: rim.frame.height / 2.5))
        rightWall.fillColor = .red
        rightWall.strokeColor = .clear
        rightWall.position = CGPoint(x: rim.position.x + 28, y: rim.position.y-43)
        rightWall.zPosition = 10
        rightWall.alpha = grids ? 1 : 0

        rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.frame.size)
        rightWall.physicsBody?.categoryBitMask = PhysicsCatory.rightBarrier
        rightWall.physicsBody?.collisionBitMask = PhysicsCatory.ball
        rightWall.physicsBody?.contactTestBitMask = PhysicsCatory.none
        rightWall.physicsBody?.affectedByGravity = false
        rightWall.physicsBody?.isDynamic = false
        self.addChild(rightWall)
        
        //Points label
        pointsLabel.text = "0"
        pointsLabel.fontName = "MarkerFelt-Wide"
        pointsLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height * 4 / 5)
        pointsLabel.fontSize = self.frame.width / 10
        pointsLabel.zPosition = bg.zPosition + 1
        self.addChild(pointsLabel)
        
        //Countdown timer
        countdownLabel.text = "90"
        countdownLabel.fontName = "MarkerFelt-Wide"
        countdownLabel.position = CGPoint(x: self.frame.width / 5, y: self.frame.height * 4 / 2)
        countdownLabel.fontSize = self.frame.width / 10
        countdownLabel.zPosition = bg.zPosition + 1
        self.addChild(countdownLabel)

        setBall()
    }

    // Set up the ball
    func setBall() {

        // Remove and reset incase the ball was previously thrown
        basketball.removeFromParent()
        ball.removeFromParent()
        
        // Reset size of ball
        ball.setScale(1)

        // Set up ball
        ball = SKShapeNode(circleOfRadius: rim.frame.width / 2)
        ball.fillColor = grids ? .blue : .clear
        ball.strokeColor = .clear
        ball.position = CGPoint(x: self.frame.width / 2, y: startG.position.y + ball.frame.height)
        ball.zPosition = 10
        basketball.size = ball.frame.size

        ball.addChild(basketball)

        ball.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "basketball"), size: basketball.size)
        ball.physicsBody?.categoryBitMask = PhysicsCatory.ball
        ball.physicsBody?.collisionBitMask = PhysicsCatory.ballGround
        ball.physicsBody?.contactTestBitMask = PhysicsCatory.base
        ball.physicsBody?.affectedByGravity = true
        ball.physicsBody?.isDynamic = true
        self.addChild(ball)
    }
//
//    // keeping this temporarily as an example of getting random number
//    func setWind() {
//        let multi = CGFloat(50)
//        let rnd = CGFloat(arc4random_uniform(UInt32(10))) - 5
//
//        windLbl.text = "Wind: \(rnd)"
//        wind = rnd * multi
//    }
//
    func throwBall() {

        let xChange = end.x - start.x
        let angle = (atan(xChange / (end.y - start.y)) * 180 / pi)
        let amendedX = (tan(angle * pi / 180) * yVel) * 0.5

        let throwVec = CGVector(dx: amendedX, dy: yVel)
        ball.physicsBody?.applyImpulse(throwVec, at: start)

        ball.run(SKAction.scale(by: 0.3, duration: airTime))

        // Change Collision Bitmask
        let wait = SKAction.wait(forDuration: airTime / 2)
        let changeCollision = SKAction.run({
            self.ball.physicsBody?.collisionBitMask = PhysicsCatory.ballGround | PhysicsCatory.netGround | PhysicsCatory.base | PhysicsCatory.leftBarrier | PhysicsCatory.rightBarrier
            self.ball.zPosition = self.bg.zPosition + 2
        })
        
        let push = SKAction.applyImpulse(CGVector(dx: 0, dy: 0), duration: 1)
        ball.run(SKAction.sequence([push]))
        self.run(SKAction.sequence([wait,changeCollision]))
        
        //increment or reset count
        if ball.position.x > leftWall.position.x && ball.position.x < rightWall.position.x {
            points += 1
            pointsLabel.text = "\(points)"
        }

        // Wait & reset
        let wait4 = SKAction.wait(forDuration: 4)
        let reset = SKAction.run({
            self.setBall()
        })
        self.run(SKAction.sequence([wait4,reset]))
    }
}
