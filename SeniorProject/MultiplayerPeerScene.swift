//
//  MultiplayerPeerScene.swift
//  SeniorProject
//
//  Created by Baris Yagan on 4/30/17.
//  Copyright © 2017 Baris Yagan. All rights reserved.
//

import Foundation
import SpriteKit
import MultipeerConnectivity
import Alamofire
import SwiftyJSON

var readyToMoveOn = false
let service = MultipeerConnector()

class MultiplayerPeerScene: SKScene {
    
    var player1: SKLabelNode
    var player2: SKLabelNode
    var player3: SKLabelNode
    var player4: SKLabelNode
    var player5: SKLabelNode
    var player6: SKLabelNode
    var player7: SKLabelNode
    var scoreBoardButton: SKLabelNode
    
    var playerList = [SKLabelNode]()
    
    var delegatePeer : MultiplayerPeerDelegate?
    
    
    override init(size: CGSize) {
        delegatePeer = service.self
        
        player1 = SKLabelNode(fontNamed: "The Bold Font")
        player2 = SKLabelNode(fontNamed: "The Bold Font")
        player3 = SKLabelNode(fontNamed: "The Bold Font")
        player4 = SKLabelNode(fontNamed: "The Bold Font")
        player5 = SKLabelNode(fontNamed: "The Bold Font")
        player6 = SKLabelNode(fontNamed: "The Bold Font")
        player7 = SKLabelNode(fontNamed: "The Bold Font")
        scoreBoardButton = SKLabelNode(fontNamed: "The Bold Font")
        
        super.init(size: size)
        
        service.delegate = self as? MultipeerConnectorDelegate
    }
    
    deinit {
        //service.session.disconnect()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        service.advertiser.startAdvertisingPeer()
        service.browser.startBrowsingForPeers()
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        player1.text = "<<empty>>"
        player1.fontSize = 130
        player1.color = SKColor.white
        player1.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.9)
        player1.zPosition = 1
        player1.name = "player1"
        playerList.append(player1)
        self.addChild(player1)
        
        
        player2.text = "<<empty>>"
        player2.fontSize = 130
        player2.color = SKColor.white
        player2.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.8)
        player2.zPosition = 1
        player2.name = "player2"
        playerList.append(player2)
        self.addChild(player2)
        
        
        player3.text = "<<empty>>"
        player3.fontSize = 130
        player3.color = SKColor.white
        player3.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.7)
        player3.zPosition = 1
        player3.name = "player3"
        playerList.append(player3)
        self.addChild(player3)
        
        player4 = SKLabelNode(fontNamed: "The Bold Font")
        player4.text = "<<empty>>"
        player4.fontSize = 130
        player4.color = SKColor.white
        player4.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.6)
        player4.zPosition = 1
        player4.name = "player4"
        playerList.append(player4)
        self.addChild(player4)
        
        player5 = SKLabelNode(fontNamed: "The Bold Font")
        player5.text = "<<empty>>"
        player5.fontSize = 130
        player5.color = SKColor.white
        player5.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.5)
        player5.zPosition = 1
        player5.name = "player5"
        playerList.append(player5)
        self.addChild(player5)
        
        player6.text = "<<empty>>"
        player6.fontSize = 130
        player6.color = SKColor.white
        player6.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.4)
        player6.zPosition = 1
        player6.name = "player6"
        playerList.append(player6)
        self.addChild(player6)
        
        
        player7.text = "menu"
        player7.fontSize = 130
        player7.color = SKColor.white
        player7.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.1)
        player7.zPosition = 1
        player7.name = "player7"
        playerList.append(player7)
        self.addChild(player7)
        
        scoreBoardButton.text = "Scoreboard"
        scoreBoardButton.fontSize = 130
        scoreBoardButton.color = SKColor.white
        scoreBoardButton.position = CGPoint(x: self.size.width * 0.5, y: self.size.height*0.25)
        scoreBoardButton.zPosition = 1
        scoreBoardButton.name = "scoreBoard"
        self.addChild(scoreBoardButton)
        
        if Reachability.isConnectedToNetwork() {
            commitNonCommitedPoints()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if readyToMoveOn {
            moveToGameScene()
        }
        updatePlayerLabels()
        /*for i in 0..<peerList.count {
         playerList[i].text = peerList[i].displayName
         }*/
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            
            let pointOfTouch = touch.location(in: self)
            let nodeITapped = atPoint(pointOfTouch)
            
            if nodeITapped.name == player1.name {
                
                self.delegatePeer?.inviteP(peerID: peerList[0])
                preparingGame()
                
            } else if nodeITapped.name == player2.name {
                self.delegatePeer?.inviteP(peerID: peerList[1])
                preparingGame()
                
            } else if nodeITapped.name == player3.name {
                self.delegatePeer?.inviteP(peerID: peerList[2])
                preparingGame()
                
            } else if nodeITapped.name == player4.name {
                self.delegatePeer?.inviteP(peerID: peerList[3])
                
            } else if nodeITapped.name == player5.name {
                self.delegatePeer?.inviteP(peerID: peerList[4])
                
            } else if nodeITapped.name == player6.name {
                self.delegatePeer?.inviteP(peerID: peerList[5])
                
            } else if nodeITapped.name == player7.name {
                //self.delegatePeer?.inviteP(peerID: peerList[6])
                service.browser.stopBrowsingForPeers()
                service.advertiser.stopAdvertisingPeer()
                let sceneToMoveTo = MainMenuScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTrasition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition:  myTrasition)
            
            } else if nodeITapped.name == scoreBoardButton.name {
                let sceneToMoveTo = ScoreBoardScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTrasition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition:  myTrasition)
            }
            
        }
    }
    func commitNonCommitedPoints() {
        let url = URL(string: "http://35.187.26.91:3000/posts")
        Alamofire.request(url!, method: .get).validate().responseJSON { response in
            switch response.result {
                
            case .success(let value):
                var id = 0
                let json = JSON(value)
                var newPlayer = true
                for (_,subJson):(String, JSON) in json {
                    for (key,subJson):(String, JSON) in subJson {
                        if (key == "id") {
                            id = subJson.int!
                        }
                        if (key != "id") {
                            
                            if (key == UIDevice.current.name) {
                                newPlayer = false
                                let currentScore = Int (subJson.stringValue)!
                                let defaults = UserDefaults()
                                let nonCommittedScore = defaults.integer(forKey: "nonCommittedP")
                                let newScore = (String)(currentScore + nonCommittedScore)
                                let params: [String: String] = [
                                    key : newScore
                                ]
                                let newUrlS = "http://35.187.26.91:3000/posts/\(id)"
                                let newUrl = URL(string: newUrlS)
                                Alamofire.request(newUrl!, method: .patch, parameters: params).validate()
                                
                            }
                        }
                    }
                }
                if newPlayer {
                    let defaults = UserDefaults()
                    let nonCommittedScore = defaults.integer(forKey: "nonCommittedP")
                    let params: [String: String] = [
                        UIDevice.current.name : String(nonCommittedScore)
                    ]
                    Alamofire.request(url!, method: .post, parameters: params).validate()
                }
            case .failure(let error):
                print(error)
            }
        }
        let defaults = UserDefaults()
        defaults.set(0, forKey: "nonCommittedP")
    }
    func updatePlayerLabels() {
        
        for index in 0..<playerList.count - 1 {
            let isIndexValid = peerList.indices.contains(index)
            if isIndexValid {
                playerList[index].text = peerList[index].displayName
            } else {
                playerList[index].text = "<<empty>>"
            }
        }
    }
    
    func preparingGame() {
        
        self.removeAllChildren()
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        let prep = SKLabelNode(fontNamed: "The Bold Font")
        prep.text = "preparing the game"
        prep.fontSize = 100
        prep.color = SKColor.white
        prep.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.5)
        prep.zPosition = 1
        prep.name = "prep"
        self.addChild(prep)
        
        
    }
    
    
    
    func moveToGameScene() {
        let sceneToMoveTo = GameScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTrasition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition:  myTrasition)
    }
    
    
    
}

protocol MultiplayerPeerDelegate {
    func inviteP(peerID: MCPeerID)
}
