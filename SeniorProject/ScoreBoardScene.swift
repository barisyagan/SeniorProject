//
//  ScoreBoardScene.swift
//  SeniorProject
//
//  Created by Baris Yagan on 5/25/17.
//  Copyright © 2017 Baris Yagan. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SpriteKit

class ScoreBoardScene: SKScene {
    
    
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        //http://35.187.26.91:3000/posts
        let url = URL(string: "http://localhost:3000/posts")
        
        Alamofire.request(url!, method: .get).validate().responseJSON { response in
            switch response.result {
                
            case .success(let value):
                
                var scoreTable = [String : String]()
                let json = JSON(value)
                
                for (_,subJson):(String, JSON) in json {
                    
                    for (key,subSubJson):(String, JSON) in subJson {
                        
                        if (key != "id") {
                            
                            //if (peerNameList.contains(key) || UIDevice.current.name == key) {
                                scoreTable[key] = subSubJson.stringValue
                            
                            //}
                        }
                    }
                    
                }
                let scoreTableSorted = self.sortDictionaryByValue(scoreTable: scoreTable)
                self.initiateLabelsFrom(scoreTable: scoreTableSorted)
                
            case .failure(let error):
                print(error)
            }
           
        }
        
       
        
    }
    
    
    /*
    func initateLabelsFrom(key: String, subSubJson: JSON, rowIndex: CGFloat) {
        let labelPlayer = SKLabelNode(fontNamed: "The Bold Font")
        let labelScore = SKLabelNode(fontNamed: "The Bold Font")
        
        let y = self.size.height * (10 - rowIndex) * 0.1
        
        self.setLabel(label: labelPlayer, text: key, fontSize: 100, fontColor: SKColor.yellow, alignment: .left, x: self.size.width*0.1 , y: y, zPosition: 1, alpha: 1, scale: 1)
        self.setLabel(label: labelScore, text: subSubJson.stringValue, fontSize: 100, fontColor: SKColor.yellow, alignment: .right, x: self.size.width*0.8, y: y, zPosition: 1, alpha: 1, scale: 1)
        
        self.addChild(labelPlayer)
        self.addChild(labelScore)
    }
    */
    
    func sortDictionaryByValue(scoreTable: [String : String]) -> [(key: String, value : String)] {
        let scoreTableSorted = scoreTable.sorted { (first: (key: String, value: String), second: (key: String, value: String)) -> Bool in
            return first.value < second.value
        }
        return scoreTableSorted
    }
    
    func initiateLabelsFrom(scoreTable: [(key: String, value: String)]) {
        var rowIndex: CGFloat = 1
        for (name, score) in scoreTable {
     
            let labelPlayer = SKLabelNode(fontNamed: "The Bold Font")
            let labelScore = SKLabelNode(fontNamed: "The Bold Font")
            
            let y = self.size.height * (10 - rowIndex) * 0.1
                
            setLabel(label: labelPlayer, text: name, fontSize: 100, fontColor: SKColor.yellow, alignment: .left, x: self.size.width*0.1 , y: y, zPosition: 1, alpha: 1, scale: 1)
            setLabel(label: labelScore, text: score, fontSize: 100, fontColor: SKColor.yellow, alignment: .right, x: self.size.width*0.8, y: y, zPosition: 1, alpha: 1, scale: 1)
            
            self.addChild(labelPlayer)
            self.addChild(labelScore)
            
            rowIndex += 1
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
