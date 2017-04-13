//
//  GameScene.swift
//  SeniorProject
//
//  Created by Baris Yagan on 11/29/16.
//  Copyright © 2016 Baris Yagan. All rights reserved.
//

import SpriteKit

var gameScore = 0


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    let service = MultipeerConnector()
    
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    let tapToStartLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    //var livesNumber = 1
    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    let player = SKSpriteNode(imageNamed: "plane")
    let enemy = SKSpriteNode(imageNamed: "enemy")
    
    let gameArea: CGRect
    
    var levelNumber = 0
    
    let explosionSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    
    let invisibleCenter = SKSpriteNode()
    
    let fireParticle = SKEmitterNode(fileNamed: "FireParticle.sks")
    let smokeParticle = SKEmitterNode(fileNamed: "SmokeParticle.sks")
    
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
    
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    var amountToMovePerSecond: CGFloat = 600.0

    var preDirection = 0
    
    var playerYPos: CGFloat = 180
    var enemyYPos: CGFloat = 180
    
    //didMove(to:) Called immediately after a scene is presented by a view.
    override func didMove(to view: SKView) {
        
        service.delegate = self
       
        //let model: GameModel = GameModel(gameScene: self)
        
        gameScore = 0
        
        self.physicsWorld.contactDelegate = self
       
        initiateBackgroundNodes()
        
        initiatePlayerNode()
        
        initiateEnemyNode()
        
        initiateScoreLabel()
        
        initiateTapToStartLabel()
        
        moveLabelsIn()
        
        initiateRainEmitterNode()
        
        
    }
    
    /* update(_:) Performs any scene-specific updates that need to occur
     before scene actions are evaluated. It is called exactly once per frame,
     so long as the scene is presented in a view and is not paused. */
    override func update(_ currentTime: TimeInterval) {
        //Background scrolling
        //invisibleCenter.zRotation -= 0.001
        
        if (lastUpdateTime == 0){
            lastUpdateTime = currentTime
        }
        else {
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
        
        self.enumerateChildNodes(withName: "Background"){
            background, stop in
            if (self.currentGameState == gameState.inGame) {
                background.position.y -= amountToMoveBackground
            }
            if (background.position.y < -self.size.height) {
                background.position.y += self.size.height * 2
            }
        }
    }
    
    var i = 0
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if currentGameState == gameState.preGame {
            startGame()
        }
        else  {
            
            
            if (i == 0) {
                //service.send(flag: "1")
                movePlayerRight()
                
                i = 1
            } else {
                //service.send(flag: "0")
                movePlayerLeft()
                
                i = 0
            }
            
            addScore()
        }
    }
    
    // didBegin(_:) Called when two bodies first contact each other.
    func  didBegin(_ contact: SKPhysicsContact) {
        //if the player has hit the cloud
        if contact.bodyA.categoryBitMask == PhysicsCategories.Player && contact.bodyB.categoryBitMask == PhysicsCategories.Cloud {
            if contact.bodyA.node != nil {
                spawnExplosion(contact.bodyA.node!.position)
            }
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            
            runGameOver()
        }
    }
    
    override init(size: CGSize) {
        let aspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height/aspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*******************
     ////////VIEW////////
     *******************/
    
    func initiateBackgroundNodes() {
        
        for i in 0...1{
            let background = SKSpriteNode(imageNamed: "background")
            background.size = self.size
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
            background.position = CGPoint(x: self.size.width/2, y: self.size.height*CGFloat(i))
            background.zPosition = 0
            background.name = "Background"
            self.addChild(background)
        }
    }
    
    
    func initiatePlayerNode() {
        player.setScale(1)
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height)
        player.zPosition = 3
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Cloud
        player.addChild(fireParticle!)
        player.addChild(smokeParticle!)
        self.addChild(player)
    }
    
    func initiateEnemyNode() {
        enemy.setScale(1)
        enemy.position = CGPoint(x: self.size.width/2, y: 0 - enemy.size.height)
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Player
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Cloud
        //enemy.addChild(fireParticle!)
        //enemy.addChild(smokeParticle!)
        self.addChild(enemy)
    }
    
    func initiateScoreLabel() {
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width * 0.15, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
    }
    
    func initiateLivesLabel() {
        livesLabel.text = "Lives: 1"
        livesLabel.fontSize = 70
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width * 0.85, y: self.size.height + livesLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
    }
    
    func initiateTapToStartLabel() {
        tapToStartLabel.text = "Tap To Begin"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
    }
    
    func initiateRainEmitterNode() {
        invisibleCenter.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        
        let rainCloud = SKEmitterNode(fileNamed: "RainParticle.sks")
        invisibleCenter.addChild(rainCloud!)
        rainCloud?.position = CGPoint(x: 0, y: self.size.height * 2)
        
        self.addChild(invisibleCenter)
    }
    
    /*************************
     ////////CONTROLLER////////
     *************************/
    
    func moveLabelsIn() {
        let moveOnToScreenAction = SKAction.moveTo(y: self.size.height*0.9, duration: 0.3)
        scoreLabel.run(moveOnToScreenAction)
        livesLabel.run(moveOnToScreenAction)
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeInAction)
    }
    
    func startGame() {
        currentGameState = gameState.inGame
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence)
        
        let movePlaneOntoScreenAction = SKAction.moveTo(y: self.size.height*0.2, duration: 0.5)
        let moveEnemyOntoScreenAction = SKAction.moveTo(y: self.size.height*0.2, duration: 0.7)
        let startCloudAction = SKAction.run(startCloudMovements)
        let startGameSequence = SKAction.sequence([movePlaneOntoScreenAction, startCloudAction])
        enemy.run(moveEnemyOntoScreenAction)
        player.run(startGameSequence)
    }
    
    func movePlayerRight() {
        playerYPos += 40
        
        let pointR = CGPoint(x: self.size.width, y: playerYPos)
        let moveR = SKAction.move(to: pointR, duration: 1)
        let moveRA = SKAction.animate(with: [SKTexture.init(imageNamed: "playerR")], timePerFrame: 1)
        
        player.run(moveRA)
        player.run(moveR)
    }
    
    func movePlayerLeft() {
        playerYPos += 40
        
        let pointL = CGPoint(x: 0, y: playerYPos)
        let moveL = SKAction.move(to: pointL, duration: 1)
        let moveLA = SKAction.animate(with: [SKTexture.init(imageNamed: "playerL")], timePerFrame: 1)
        
        player.run(moveLA)
        player.run(moveL)
    }
    
    func moveEnemyRight() {
        enemyYPos += 40
        
        let pointR = CGPoint(x: self.size.width, y: enemyYPos)
        let moveR = SKAction.move(to: pointR, duration: 1)
        let moveRA = SKAction.animate(with: [SKTexture.init(imageNamed: "enemyR")], timePerFrame: 1)
        
        enemy.run(moveRA)
        enemy.run(moveR)
    }
    
    func moveEnemyLeft() {
        enemyYPos += 40
        
        let pointL = CGPoint(x: 0, y: enemyYPos)
        let moveL = SKAction.move(to: pointL, duration: 1)
        let moveLA = SKAction.animate(with: [SKTexture.init(imageNamed: "enemyL")], timePerFrame: 1)
        
        enemy.run(moveLA)
        enemy.run(moveL)
    }
    
    func startCloudMovements() {
        
        if self.action(forKey: "spawningClouds") != nil {
            self.removeAction(forKey: "spawningClouds")
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
        self.run(spawnForever, withKey: "spawningClouds")
    }
    
    func spawnCloudFromTop() {
        
        invisibleCenter.zRotation = 0
        smokeParticle?.emissionAngle = 4.71
        fireParticle?.emissionAngle = 4.71
        
        var randomNumber: Int = Int(random(min:0, max:3))
        randomNumber = randomNumber * 360
        //var randomXStart: Int = random(min: gameArea.minX, max: gameArea.maxX)
        
        let randomXStart: CGFloat = CGFloat((randomNumber) + (178))
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXStart, y: -self.size.height * 0.2)
        
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
        self.addChild(cloud)
        
        let moveCloud = SKAction.move(to: endPoint, duration: 2)
        let removeCloud = SKAction.removeFromParent()
        //let loseALifeAction = SKAction.run(loseALife)
        let cloudSequence = SKAction.sequence([moveCloud, removeCloud] )
        
        if currentGameState == gameState.inGame {
            cloud.run(cloudSequence)
        }
    }
    
    func spawnExplosion(_ spawnPosition: CGPoint) {
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
    
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let remove = SKAction.removeFromParent()
        
        let exploisonSequence = SKAction.sequence([explosionSound,scaleIn, fadeOut, remove])
        
        explosion.run(exploisonSequence)
    }
    
    func runGameOver() {
        currentGameState = gameState.afterGame
        self.removeAllActions()
        self.enumerateChildNodes(withName: "Cloud"){
            enemy, stop in
            enemy.removeAllActions()
        }
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
    }
    
    func changeScene() {
        
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
        
    }
    
    func addScore() {
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
    }
    
    //utility
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
}

extension GameScene : MultipeerConnectorDelegate {
    
    func connectedDevicesChanged(manager: MultipeerConnector, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            
        }
    }
    
    func numberChanged(manager: MultipeerConnector, numberString: String) {
        OperationQueue.main.addOperation {
            switch numberString {
                
            case "1":
                
                self.moveEnemyRight()
                
                /*let pointR = CGPoint(x: self.size.width, y: 180 + self.a)
                //let pointL = CGPoint(x: 0, y: 180 + self.a)
                let moveR = SKAction.move(to: pointR, duration: 1)
                //let moveL = SKAction.move(to: pointL, duration: 1)
                let moveRA = SKAction.animate(with: [SKTexture.init(imageNamed: "enemyR")], timePerFrame: 1)
                //let moveLA = SKAction.animate(with: [SKTexture.init(imageNamed: "enemyL")], timePerFrame: 1)
 
                self.enemy.run(moveRA)
                self.enemy.run(moveR)
                */
            case "0":
                
                self.movePlayerLeft()
                /*
                //let pointR = CGPoint(x: self.size.width, y: 180 + self.a)
                let pointL = CGPoint(x: 0, y: 180 + self.a)
                //let moveR = SKAction.move(to: pointR, duration: 1)
                let moveL = SKAction.move(to: pointL, duration: 1)
                //let moveRA = SKAction.animate(with: [SKTexture.init(imageNamed: "enemyR")], timePerFrame: 1)
                let moveLA = SKAction.animate(with: [SKTexture.init(imageNamed: "enemyL")], timePerFrame: 1)
                
                self.enemy.run(moveLA)
                self.enemy.run(moveL)
                  */
            default: break
            }
        }
            
    }

}

/*func spawnCloudFromTopRight() {
 
 invisibleCenter.zRotation = -0.45
 smokeParticle?.emissionAngle = 3.93
 fireParticle?.emissionAngle = 3.93
 
 let randomXStart = random(min: gameArea.minX*2, max: gameArea.maxX*2)
 
 
 let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
 let endPoint = CGPoint(x: randomXStart-(gameArea.maxX/2), y: -self.size.height * 0.2)
 
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
 self.addChild(cloud)
 
 let moveCloud = SKAction.move(to: endPoint, duration: 2)
 let removeCloud = SKAction.removeFromParent()
 //let loseALifeAction = SKAction.run(loseALife)
 let cloudSequence = SKAction.sequence([moveCloud, removeCloud] )
 
 if currentGameState == gameState.inGame {
 cloud.run(cloudSequence)
 }
 
 }
 
 func spawnCloudFromRight() {
 
 invisibleCenter.zRotation = -1.45
 smokeParticle?.emissionAngle = 3.14
 fireParticle?.emissionAngle = 3.14
 
 let randomYStart = random(min: gameArea.minY, max: gameArea.maxY)
 
 
 let startPoint = CGPoint(x: self.size.width * 1.2, y: randomYStart)
 let endPoint = CGPoint(x: -self.size.width * 0.2, y: randomYStart)
 
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
 self.addChild(cloud)
 
 let moveCloud = SKAction.move(to: endPoint, duration: 2)
 let removeCloud = SKAction.removeFromParent()
 //let loseALifeAction = SKAction.run(loseALife)
 let cloudSequence = SKAction.sequence([moveCloud, removeCloud] )
 
 if currentGameState == gameState.inGame {
 cloud.run(cloudSequence)
 }
 
 }
 
 func spawnCloudFromTopLeft() {
 
 invisibleCenter.zRotation = 0.45
 smokeParticle?.emissionAngle = 5.49
 fireParticle?.emissionAngle = 5.49
 
 let randomxStart = random(min: -gameArea.maxX/2, max: gameArea.minX*4)
 
 
 let startPoint = CGPoint(x: randomxStart, y: self.size.height * 1.2)
 let endPoint = CGPoint(x: randomxStart+(gameArea.maxX*1.2), y: -self.size.height * 0.2)
 
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
 self.addChild(cloud)
 
 let moveCloud = SKAction.move(to: endPoint, duration: 2)
 let removeCloud = SKAction.removeFromParent()
 //let loseALifeAction = SKAction.run(loseALife)
 let cloudSequence = SKAction.sequence([moveCloud, removeCloud] )
 
 if currentGameState == gameState.inGame {
 cloud.run(cloudSequence)
 }
 
 }
 
 func spawnCloudFromLeft() {
 
 invisibleCenter.zRotation = 1.45
 smokeParticle?.emissionAngle = 0
 fireParticle?.emissionAngle = 0
 
 let randomYStart = random(min: gameArea.minY, max: gameArea.maxY)
 
 
 let startPoint = CGPoint(x: -self.size.width * 0.2, y: randomYStart)
 let endPoint = CGPoint(x: self.size.width * 1.2, y: randomYStart)
 
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
 self.addChild(cloud)
 
 let moveCloud = SKAction.move(to: endPoint, duration: 2)
 let removeCloud = SKAction.removeFromParent()
 //let loseALifeAction = SKAction.run(loseALife)
 let cloudSequence = SKAction.sequence([moveCloud, removeCloud] )
 
 if currentGameState == gameState.inGame {
 cloud.run(cloudSequence)
 }
 
 }*/
