//
//  ScoreBoardScene.swift
//  SeniorProject
//
//  Created by Baris Yagan on 5/25/17.
//  Copyright © 2017 Baris Yagan. All rights reserved.
//

import Foundation
import SpriteKit

class ScoreBoardScene: SKScene {
    
    var playerLabels: [SKLabelNode] = []
    var scoreLabels: [SKLabelNode] = []
    var scoreTable: [String : String] = [:]
    
    override func didMove(to view: SKView) {
        
        let httpHandler = HTTPHandler()
        
        scoreTable = httpHandler.getScoreTable()
        
        initiateLabelsFrom(scoreTable: scoreTable)

        
       
        
    }
    
    
    
    func initiateLabelsFrom(scoreTable: [String : String]) {
        let rowIndex: CGFloat = CGFloat(scoreTable.count)
        
        for (name, score) in scoreTable {
            
            let labelPlayer = SKLabelNode(fontNamed: "The Bold Font")
            let labelScore = SKLabelNode(fontNamed: "The Bold Font")
            
            let y = self.size.height * rowIndex * 0.1
                
            setLabel(label: labelPlayer, text: name, fontSize: 100, fontColor: SKColor.yellow, alignment: .left, x: self.size.width*0.1 , y: y, zPosition: 1, alpha: 1, scale: 1)
            setLabel(label: labelScore, text: score, fontSize: 100, fontColor: SKColor.yellow, alignment: .right, x: self.size.width*0.8, y: y, zPosition: 1, alpha: 1, scale: 1)
            
            self.addChild(labelPlayer)
            self.addChild(labelScore)
        }
        
        
    }
    
    func setLabel(label: SKLabelNode, text: String, fontSize: CGFloat, fontColor: SKColor, alignment: SKLabelHorizontalAlignmentMode, x: CGFloat, y: CGFloat, zPosition: CGFloat, alpha: CGFloat, scale: CGFloat) {
        
        label.text = text
        label.fontSize = fontSize
        label.fontColor = fontColor
        label.horizontalAlignmentMode = alignment
        label.position = CGPoint(x: x, y: y)
        label.zPosition = zPosition
        label.alpha = alpha
        label.setScale(scale)
    }
    
    
}