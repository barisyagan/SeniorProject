//
//  Plane.swift
//  SeniorProject
//
//  Created by Baris Yagan on 5/9/17.
//  Copyright © 2017 Baris Yagan. All rights reserved.
//

import Foundation
import SpriteKit


class Plane {

    let node: SKSpriteNode
    let imageName: String
    var yCoor: CGFloat
    var direction: Bool
    
    let fireParticle = SKEmitterNode(fileNamed: "FireParticle.sks")
    let smokeParticle = SKEmitterNode(fileNamed: "SmokeParticle.sks")
    
    let size: CGSize
    
    init(imageName: String, size: CGSize) {
        
        self.imageName = imageName
        self.size = size
        
        node = SKSpriteNode(imageNamed: imageName)
        node.name = self.imageName
        node.setScale(1)
        node.position = CGPoint(x: self.size.width/2, y: 0 - node.size.height)
        node.zPosition = 3
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody!.affectedByGravity = false
        if (node.name == "enemy") {
            node.physicsBody!.categoryBitMask = 0b11 //0b11 = 3 = Enemy (PhysicsCategories)
        } else {
            node.physicsBody!.categoryBitMask = 0b1 //0b1 =  1 = Player (PhysicsCategories)
        }
        
        node.physicsBody!.collisionBitMask = 0 // 0 = None (PhysicsCategories)
        node.physicsBody!.contactTestBitMask = 0b10 // 0b10 = 2 = Cloud (PhysicsCategories)
        node.addChild(fireParticle!)
        node.addChild(smokeParticle!)
        
        fireParticle?.name = "fireParticle"
        smokeParticle?.name = "smokeParticle"
        
        smokeParticle?.emissionAngle = 4.71
        fireParticle?.emissionAngle = 4.71
        
        yCoor = 180
        direction = false
    }
    
    func pokeToMove() {
        yCoor += 40
        
        let xCoor: CGFloat
        var directionalImageName = imageName
        
        // false is left, true is right
        if direction == false {
            xCoor = 0
            directionalImageName += "L"
            direction = true
        } else {
            xCoor = size.width
            directionalImageName += "R"
            direction = false
        }
        
        let point = CGPoint(x: xCoor, y: yCoor)
        let moveAction = SKAction.move(to: point, duration: 1)
        let moveAnimation = SKAction.animate(with: [SKTexture.init(imageNamed: directionalImageName)], timePerFrame: 1)
        
        node.run(moveAnimation)
        node.run(moveAction)
        
       
        
    }
    
    func flyIntoScreen(duration: TimeInterval) {
        let moveIntoScreenAction = SKAction.moveTo(y: size.height*0.2, duration: duration)
        node.run(moveIntoScreenAction)
    }
}
