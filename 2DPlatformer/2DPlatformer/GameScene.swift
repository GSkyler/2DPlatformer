//
//  GameScene.swift
//  2DPlatformer
//
//  Created by conant cougars on 1/27/20.
//  Copyright © 2020 Scioly. All rights reserved.
//

import SpriteKit
import GameplayKit

import CoreMotion

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var playerSprite : SKSpriteNode?
    private var passCategory : UInt32 = 0
    private var collideCategory : UInt32 = 1
    private var cam = SKCameraNode()
    private var platformSprites : Array<SKSpriteNode> = []
    private var scoreLabel : SKLabelNode?
    
    private var timeSpeedIncrease : Double = 0
    private var topPlatformY : Int = 0
    private var cameraYShift : Double = 0
    private var score : Int = 0
    
    private var didLose = false
    
    private var motionManager : CMMotionManager?
    
    override func didMove(to view: SKView) {
        
        reset()
        
        addChild(cam)
        camera = cam
        
        removePlatforms()
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel?.fontSize = 50
        self.addChild(scoreLabel!)
        
        playerSprite!.physicsBody?.collisionBitMask = 0b0001
        
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.score += 10
            self.timeSpeedIncrease = Double(self.score / 1000) / 2.0
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if !didLose {
            if let player = self.playerSprite {
                player.physicsBody = SKPhysicsBody(rectangleOf: CGSize.init(width: 80, height: 80))
                player.physicsBody?.applyImpulse(CGVector.init(dx: -(player.physicsBody?.velocity.dx)!, dy: 250))
                removePlatforms()
            }
            
        }
        else {
            reset()
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
        print("reset called")
        camera?.position.y -= CGFloat(cameraYShift)
        cameraYShift = 0
        
        score  = 0
        
        for platform in platformSprites {
            platform.removeFromParent()
            platformSprites.remove(at: platformSprites.firstIndex(of: platform)!)
        }
        
        self.playerSprite = self.childNode(withName: "playerSprite") as? SKSpriteNode
        
        let baseSprite = SKSpriteNode(color: UIColor.systemTeal, size: CGSize(width: frame.width, height: CGFloat(200)))
        baseSprite.position.y = 200 + frame.height / -2
        baseSprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize.init(width: frame.width, height: 200))
        baseSprite.physicsBody?.affectedByGravity = false
        baseSprite.physicsBody?.isDynamic = false
        baseSprite.physicsBody?.categoryBitMask = 0b0001
        baseSprite.physicsBody?.fieldBitMask = playerSprite?.physicsBody!.fieldBitMask ?? 4294967295
        
        topPlatformY = Int(baseSprite.position.y)
        
        self.addChild(baseSprite)
        
        playerSprite?.position.x = 0
        playerSprite?.position.y = 400 + frame.height / -2
        playerSprite?.physicsBody?.velocity = CGVector.init(dx: 0, dy: 0)
        
        self.view?.isPaused = false
        didLose = false
    }
    
    func checkMakeNewPlatform() {
        let topScreenY =  cameraYShift + Double(self.frame.height/2)
        if (topPlatformY < Int(topScreenY - 300)) {
            let newSprite = SKSpriteNode(color: UIColor.systemTeal, size: CGSize.init(width: frame.width-400, height: 40))
            newSprite.position.y = CGFloat(topPlatformY + 300)
            topPlatformY += 300
            newSprite.position.x = CGFloat(Int.random(in: -125..<125))
            newSprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize.init(width: frame.width-400, height: 40))
            newSprite.physicsBody?.affectedByGravity = false
            newSprite.physicsBody?.isDynamic = false
            newSprite.physicsBody?.categoryBitMask = 0b0001
            newSprite.physicsBody?.fieldBitMask = playerSprite?.physicsBody!.fieldBitMask ?? 4294967295
            
            platformSprites.append(newSprite)
            self.addChild(newSprite)
        }
        
    }
    
    func checkLose() {
        let topScreenY = CGFloat(cameraYShift) + self.frame.height/2
        let botScreenY = CGFloat(cameraYShift) - self.frame.height/2
        let leftScreenX = self.frame.width / -2
        let rightScreenX = self.frame.width / 2
        if ((playerSprite?.position.x)! > rightScreenX || (playerSprite?.position.x)! < leftScreenX || (playerSprite?.position.y)! > topScreenY || (playerSprite?.position.y)! < botScreenY) {
            self.view?.isPaused = true
            didLose = true
        }
        
    }
    
    func updateScoreLabel() {
        scoreLabel?.text = "\(score)"
        scoreLabel?.position.x = 0
        scoreLabel?.position.y = CGFloat(cameraYShift) - 50 + self.frame.height/2
        
    }
    
    func removePlatforms() {
        let botScreenY = CGFloat(cameraYShift)
        
        for platform in platformSprites {
            print("platform y: \(platform.position.y) , botScreenY \(botScreenY)")
            if (platform.position.y < botScreenY) {
                platform.removeFromParent()
            }
            platformSprites.remove(at: platformSprites.firstIndex(of: platform)!)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if let accelerometerData = motionManager?.accelerometerData{
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.x * 45, dy: -9.8)
        }
        
        cam.position.y += 2.5 + CGFloat(timeSpeedIncrease)
        cameraYShift += 2.5 + timeSpeedIncrease
        
        updateScoreLabel()
        checkMakeNewPlatform()
        removePlatforms()
        checkLose()
        
    }
}
