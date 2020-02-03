//
//  GameScene.swift
//  2DPlatformer
//
//  Created by conant cougars on 1/27/20.
//  Copyright © 2020 Scioly. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var playerSprite : SKSpriteNode?
    private var platformSprite : SKSpriteNode?
    private var passCategory : UInt32 = 0
    private var collideCategory : UInt32 = 1
    
//    private var motionManager : CMMotionManager?
    
    override func didMove(to view: SKView) {
        
//      Make screen edge border of world *remove* after adding balls
        scene!.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        reset()
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        playerSprite!.physicsBody?.collisionBitMask = 0b0001
        platformSprite!.physicsBody?.collisionBitMask = 0b0010
        
//            label?.text = "\(body.velocity.dy)"
//        checkMakeNewPlatform()
        
    }
    
//    func checkMakeNewPlatform() {
//        if playerSprite?.position.y <
//    }
    
    func touchDown(atPoint pos : CGPoint) {
//        label?.text = "\(playerSprite?.physicsBody?.velocity.dy ?? 0)"
        if let player = self.playerSprite {
            player.physicsBody = SKPhysicsBody(rectangleOf: CGSize.init(width: 80, height: 80))
//            player.physicsBody?.velocity.dy
            player.physicsBody?.applyImpulse(CGVector.init(dx: 0, dy: 300))
        }
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    func reset() {
        self.playerSprite = self.childNode(withName: "playerSprite") as? SKSpriteNode
        self.platformSprite = self.childNode(withName: "platform1") as? SKSpriteNode
        
        let baseSprite = SKSpriteNode(color: UIColor.systemTeal, size: CGSize(width: frame.width, height: CGFloat(200)))
        baseSprite.position.y = -650
        baseSprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize.init(width: frame.width, height: 200))
        baseSprite.physicsBody?.categoryBitMask = 0b0001
        baseSprite.physicsBody?.fieldBitMask = playerSprite?.physicsBody!.fieldBitMask ?? 4294967295
        
        self.addChild(baseSprite)
        
        playerSprite?.position.x = 0
        playerSprite?.position.y = 200 + frame.height / -2
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
