//
//  GameModel.swift
//  SeniorProject
//
//  Created by Baris Yagan on 4/11/17.
//  Copyright © 2017 Baris Yagan. All rights reserved.
//

import SpriteKit
import Foundation


class GameModel: NSObject, SKPhysicsContactDelegate {
    
    enum gameState{
        case preGame
        case inGame
        case afterGame
    }
    
    var currentGameState = gameState.preGame
    
    struct PhysicsCategories {
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1 //1
        static let Cloud: UInt32 = 0b10 //2
    }

    
    var gameScene: SKScene!
    
    init(gameScene: SKScene) {
        self.gameScene = gameScene
        super.init()
    }
    
    
    
    /*required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }*/

    
    func startCloudMovements() {

        if gameScene.action(forKey: "spawningClouds") != nil {
            gameScene.removeAction(forKey: "spawningClouds")
        }
        
        //let spawnLeft = SKAction.run(spawnCloudFromLeft)
        //let spawnTopLeft = SKAction.run(spawnCloudFromTopLeft)
        let spawnTop = SKAction.run(spawnCloudFromTop)
        //let spawnTopRight = SKAction.run(spawnCloudFromTopRight)
        //let spawnRight = SKAction.run(spawnCloudFromRight)
        
        let waitToSpawn = SKAction.wait(forDuration: 1)
        
        //let spawnLeftSequence = SKAction.sequence([waitToSpawn, spawnLeft])
        //let spawnTopLeftSequence = SKAction.sequence([waitToSpawn, spawnTopLeft])
        let spawnTopSequence = SKAction.sequence([waitToSpawn, spawnTop])
        //let spawnTopRightSequence = SKAction.sequence([waitToSpawn, spawnTopRight])
        //let spawnRightSequence = SKAction.sequence([waitToSpawn, spawnRight])
        
        //let spawnLeftRepeatedSequence = SKAction.repeat(spawnLeftSequence, count: 3)
        //let spawnTopLeftRepeatedSequence = SKAction.repeat(spawnTopLeftSequence, count: 5)
        let spawnTopRepeatedSequence = SKAction.repeat(spawnTopSequence, count: 6)
        //let spawnTopRightRepeatedSequence = SKAction.repeat(spawnTopRightSequence, count: 5)
        //let spawnRightRepeatedSequence = SKAction.repeat(spawnRightSequence, count: 3)
        
        
        //let spawnSequence = SKAction.sequence([spawnTopRepeatedSequence, spawnTopRightRepeatedSequence, spawnRightRepeatedSequence, spawnTopRightRepeatedSequence, spawnTopRepeatedSequence, spawnTopLeftRepeatedSequence, spawnLeftRepeatedSequence, spawnTopLeftSequence])
        
        let spawnSequence = SKAction.sequence([spawnTopRepeatedSequence])
        
        let spawnForever = SKAction.repeatForever(spawnSequence)
        gameScene.run(spawnForever, withKey: "spawningClouds")
    }
    
    func spawnCloudFromTop() {
        
        /*invisibleCenter.zRotation = 0
        smokeParticle?.emissionAngle = 4.71
        fireParticle?.emissionAngle = 4.71
        */
        var randomNumber: Int = Int(random(min: 0, max: 3))
        randomNumber = randomNumber * 360
        //var randomXStart: Int = random(min: gameArea.minX, max: gameArea.maxX)
        
        let randomXStart: CGFloat = CGFloat((randomNumber) + (178))
        
        let startPoint = CGPoint(x: randomXStart, y: gameScene.size.height * 1.2)
        let endPoint = CGPoint(x: randomXStart, y: -gameScene.size.height * 0.2)
        
        let cloud = SKSpriteNode(imageNamed: "cloud")
        
        cloud.name = "Cloud"
        cloud.setScale(1)
        cloud.position = startPoint
        cloud.zPosition = 2
        cloud.physicsBody = SKPhysicsBody(rectangleOf: cloud.size)
        cloud.physicsBody!.affectedByGravity = false
        cloud.physicsBody!.categoryBitMask = PhysicsCategories.Cloud
        cloud.physicsBody!.collisionBitMask = PhysicsCategories.None
        cloud.physicsBody!.contactTestBitMask = PhysicsCategories.Player
        gameScene.addChild(cloud)
        
        let moveCloud = SKAction.move(to: endPoint, duration: 2)
        let removeCloud = SKAction.removeFromParent()
        //let loseALifeAction = SKAction.run(loseALife)
        let cloudSequence = SKAction.sequence([moveCloud, removeCloud] )
        
        if currentGameState == gameState.inGame {
            cloud.run(cloudSequence)
        }
    
        
    }
    
    func spawnExplosion(_ spawnPosition: CGPoint) {
        
        let explosionSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
        let explosion = SKSpriteNode(imageNamed: "explosion")
        
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        gameScene.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let remove = SKAction.removeFromParent()
        
        let exploisonSequence = SKAction.sequence([explosionSound,scaleIn, fadeOut, remove])
        
        explosion.run(exploisonSequence)
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    /*var livesNumber = 1
    
    let player = SKSpriteNode(imageNamed: "plane")
    let enemy = SKSpriteNode(imageNamed: "enemy")
    
    let gameArea: CGRect
    
    
    
    var currentGameState = gameState.preGame
    
    struct PhysicsCategories {
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1 //1
        static let Cloud: UInt32 = 0b10 //2
    }
    
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    var amountToMovePerSecond: CGFloat = 600.0
    
    var preDirection = 0
    */

}
