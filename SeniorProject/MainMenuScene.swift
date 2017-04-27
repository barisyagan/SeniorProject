//
//  MainMenuScene.swift
//  SeniorProject
//
//  Created by Baris Yagan on 12/17/16.
//  Copyright © 2016 Baris Yagan. All rights reserved.
//

import Foundation
import SpriteKit

var single = true

class MainMenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        let gameName1 = SKLabelNode(fontNamed: "The Bold Font")
        gameName1.text = "Sticky"
        gameName1.fontSize = 150
        gameName1.color = SKColor.white
        gameName1.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.7)
        gameName1.zPosition = 1
        self.addChild(gameName1)
        
        let gameName2 = SKLabelNode(fontNamed: "The Bold Font")
        gameName2.text = "Flight"
        gameName2.fontSize = 150
        gameName2.color = SKColor.white
        gameName2.position = CGPoint(x: self.size.width * 0.5, y: self.size.height*0.625)
        gameName2.zPosition = 1
        self.addChild(gameName2)
        
        let singleButton = SKLabelNode(fontNamed: "The Bold Font")
        singleButton.text = "SinglePlayer"
        singleButton.fontSize = 130
        singleButton.color = SKColor.white
        singleButton.position = CGPoint(x: self.size.width * 0.5, y: self.size.height*0.4)
        singleButton.zPosition = 1
        singleButton.name = "singlePlayer"
        self.addChild(singleButton)
        
        let multiButton = SKLabelNode(fontNamed: "The Bold Font")
        multiButton.text = "MultiPlayer"
        multiButton.fontSize = 130
        multiButton.color = SKColor.white
        multiButton.position = CGPoint(x: self.size.width * 0.5, y: self.size.height*0.15)
        multiButton.zPosition = 1
        multiButton.name = "multiPlayer"
        self.addChild(multiButton)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            
            let pointOfTouch = touch.location(in: self)
            let nodeITapped = atPoint(pointOfTouch)
            
            if (nodeITapped.name == "singlePlayer") {
                single = true
                moveToGameScene()
            }
            
            if (nodeITapped.name == "multiPlayer") {
                single = false
                moveToGameScene()
            }
        
        }
    }
    
    func moveToGameScene() {
        let sceneToMoveTo = GameScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTrasition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition:  myTrasition)
    }
}

