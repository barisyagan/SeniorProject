//
//  GameOverScene.swift
//  SeniorProject
//
//  Created by Baris Yagan on 1/2/17.
//  Copyright © 2017 Baris Yagan. All rights reserved.
//

import Foundation
import SpriteKit


import Social


class GameOverScene: SKScene {
    
    let restartLabel = SKLabelNode(fontNamed: "The Bold Font")
    let tweetLabel = SKLabelNode(fontNamed: "The Bold Font")
        
    override func didMove(to view: SKView) {
        let winResult = "has beaten"
        let loseResult = "has lost to"
        let result: String
        if winner {
            result = winResult
        } else {
            result = loseResult
        }
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        let gameOverLabel = SKLabelNode(fontNamed: "The Bold Font")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 200
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.7)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        if (single) {
        
            let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
            scoreLabel.text = "Score: \(gameScore)"
            scoreLabel.fontSize = 125
            scoreLabel.fontColor = SKColor.white
            scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.55)
            scoreLabel.zPosition = 1
            self.addChild(scoreLabel)
        
            let defaults = UserDefaults()
            var highScoreNumber = defaults.integer(forKey: "highScoreSaved")
        
            if gameScore > highScoreNumber {
                highScoreNumber = gameScore
                defaults.set(highScoreNumber, forKey: "highScoreSaved")
            }
        
            let highScoreLabel = SKLabelNode(fontNamed: "The Bold Font")
            highScoreLabel.text = "High Score: \(highScoreNumber)"
            highScoreLabel.fontSize = 125
            highScoreLabel.fontColor = SKColor.white
            highScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.45)
            highScoreLabel.zPosition = 1
            self.addChild(highScoreLabel)
            
        } else {
            
            let playerLabel = SKLabelNode(fontNamed: "The Bold Font")
            playerLabel.text = UIDevice.current.name
            playerLabel.fontSize = 125
            playerLabel.fontColor = SKColor.white
            playerLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.55)
            playerLabel.zPosition = 1
            self.addChild(playerLabel)
            
            let resultLabel = SKLabelNode(fontNamed: "The Bold Font")
            resultLabel.text = result
            resultLabel.fontSize = 125
            resultLabel.fontColor = SKColor.white
            resultLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.45)
            resultLabel.zPosition = 1
            self.addChild(resultLabel)
            
            let opponentLabel = SKLabelNode(fontNamed: "The Bold Font")
            opponentLabel.text = opponentName
            opponentLabel.fontSize = 125
            opponentLabel.fontColor = SKColor.white
            opponentLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.35)
            opponentLabel.zPosition = 1
            self.addChild(opponentLabel)
        }
        
        restartLabel.text = "Restart"
        restartLabel.fontSize = 90
        restartLabel.fontColor = SKColor.white
        restartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.3)
        restartLabel.zPosition = 1
        self.addChild(restartLabel)
        
        
        tweetLabel.text = "Tweet"
        tweetLabel.fontSize = 125
        tweetLabel.fontColor = SKColor.white
        tweetLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.15)
        tweetLabel.zPosition = 1
        self.addChild(tweetLabel)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            
            let pointOfTouch = touch.location(in: self)
            
            if restartLabel.contains(pointOfTouch) {
                
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
            
            } else if tweetLabel.contains(pointOfTouch) {
                
                if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
                    let tweet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                    if single {
                        tweet.setInitialText("Did \(gameScore) #")
                    } else {
                        tweet.setInitialText("I've beaten  \(opponentName)!!")
                    }
                    tweet.add(getScreenshot(scene: self))
                    
                    self.view?.window?.rootViewController?.present(tweet, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Accounts", message: "Please login to Twitter.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    
                    self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    func getScreenshot(scene: SKScene) -> UIImage {
        let snapshotView = scene.view!.snapshotView(afterScreenUpdates: true)
        let bounds = UIScreen.main.bounds
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        
        snapshotView?.drawHierarchy(in: bounds, afterScreenUpdates: true)
        
        let screenshotImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return screenshotImage;
    }
    
}
