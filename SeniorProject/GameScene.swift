//
//  GameScene.swift
//  SeniorProject
//
//  Created by Baris Yagan on 11/29/16.
//  Copyright © 2016 Baris Yagan. All rights reserved.
//

import SpriteKit
import GameplayKit

var gameScore = 0
var winner = true

class GameScene: SKScene, SKPhysicsContactDelegate {
    var waitingTimeLimit = 10
    var waitingTimer: Timer!
    var playerReady = false
    var enemyReady = false
    var clouds: [SKSpriteNode]
    var topCloud: SKNode
    //var totalMinute: Int = 0

    var readyToStart: Bool = false {
        didSet {
            if (!single) {
                let deleteAction = SKAction.removeFromParent()
                waitingForOpponentLabel.run(deleteAction)
            
                waitingTimer.invalidate()
            
                currentGameState = gameState.inGame
            
                //let movePlaneOntoScreenAction = SKAction.moveTo(y: self.size.height*0.2, duration: 0.5)
                //let moveEnemyOntoScreenAction = SKAction.moveTo(y: self.size.height*0.2, duration: 0.7)
                let startCloudAction = SKAction.run(startCloudMovements)
                //let startGameSequence = SKAction.sequence([movePlaneOntoScreenAction, startCloudAction])
                enemy.flyIntoScreen(duration: 0.7) //enemy.run(moveEnemyOntoScreenAction)
                player.flyIntoScreen(duration: 0.5)
                self.run(startCloudAction)//player.run(startGameSequence)
            } else {
                currentGameState = gameState.inGame
                //let movePlaneOntoScreenAction = SKAction.moveTo(y: self.size.height*0.2, duration: 0.5)
                let startCloudAction = SKAction.run(startCloudMovements)
                //let startGameSequence = SKAction.sequence([movePlaneOntoScreenAction, startCloudAction])
                player.flyIntoScreen(duration: 0.7) //player.run(startGameSequence)
                self.run(startCloudAction)
            }
        }
    }
    
    var randomNumberGenerator = GKARC4RandomSource()
    
    var scoreLabel: SKLabelNode
    var tapToStartLabel: SKLabelNode
    var readyLabel: SKLabelNode
    var waitingForOpponentLabel: SKLabelNode
    var livesLabel: SKLabelNode
    
    let player: Plane
    let enemy: Plane
    
    let gameArea: CGRect
    
    var levelNumber = 0
    
    let explosionSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    
    let invisibleCenter = SKSpriteNode()
    
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
        static let Enemy: UInt32 = 0b11 //3
    }
    
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    var amountToMovePerSecond: CGFloat = 600.0

    var preDirection = 0
    
    var playerYPos: CGFloat = 180
    var enemyYPos: CGFloat = 180
    
    //didMove(to:) Called immediately after a scene is presented by a view.
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        service.delegate = self
        winner = true
        gameScore = 0
        
        if (!single) {
            self.addChild(enemy.node)
            
            setWaitingForOpponentLabel()
            self.addChild(waitingForOpponentLabel)
        }
        
        initializeRandomNumberGenerator()
        
        initiateBackgroundNodes()
        
        self.addChild(player.node)
        
        if single {
            setScoreLabel()
            self.addChild(scoreLabel)
        }
        
        setReadyLabel()
        self.addChild(readyLabel)
        
        setTapToStartLabel()
        self.addChild(tapToStartLabel)
        
        moveLabelsIn()
        
        initiateRainEmitterNode()
        
        
    }
    
    /* update(_:) Performs any scene-specific updates that need to occur
     before scene actions are evaluated. It is called exactly once per frame,
     so long as the scene is presented in a view and is not paused. */
    override func update(_ currentTime: TimeInterval) {
        //Background scrolling
        //invisibleCenter.zRotation -= 0.001
       
        scrollBackground(currentTime: currentTime)

    }
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        if currentGameState == gameState.preGame {
            
            startGame()
            
        }
        else  {
            
            service.send(flag: "0")
            player.pokeToMove()
            
            addScore()
        }
    }
    
    // didBegin(_:) Called when two bodies first contact each other.
    func  didBegin(_ contact: SKPhysicsContact) {
        //if the player has hit the cloud
        
        startContactActions(contact: contact)
        
    }
    
    
    override init(size: CGSize) {
        let aspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height/aspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        player = Plane(imageName: "player", size: size)
        enemy = Plane(imageName: "enemy", size: size)
        
        scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
        tapToStartLabel = SKLabelNode(fontNamed: "The Bold Font")
        readyLabel = SKLabelNode(fontNamed: "The Bold Font")
        waitingForOpponentLabel = SKLabelNode(fontNamed: "The Bold Font")
        livesLabel = SKLabelNode(fontNamed: "The Bold Font")
        clouds = []
        topCloud = SKNode()
        
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
    
    func setScoreLabel() {
        
            setLabel(label: scoreLabel, text: "Score: 0", fontSize: 70, fontColor: SKColor.white, alignment: SKLabelHorizontalAlignmentMode.left, x: self.size.width * 0.15, y: size.height + scoreLabel.frame.size.height, zPosition: 100, alpha: 1, scale: 1)
        
    }
    
    func setLivesLabel() {
        
        setLabel(label: livesLabel, text: "Lives: 1", fontSize: 70, fontColor: SKColor.white, alignment: SKLabelHorizontalAlignmentMode.right, x: size.width * 0.85, y: size.height + livesLabel.frame.size.height, zPosition: 100, alpha: 1, scale: 1)
    }
    
    func setReadyLabel() {
        
        setLabel(label: readyLabel, text: "Ready?", fontSize: 150, fontColor: SKColor.yellow, alignment: SKLabelHorizontalAlignmentMode.center, x: size.width/2, y: size.height/2 - 100, zPosition: 1, alpha: 0, scale: 1)
        
    }
    
    func setTapToStartLabel() {
        
        setLabel(label: tapToStartLabel, text: "tap tap tap", fontSize: 70, fontColor: SKColor.white, alignment: SKLabelHorizontalAlignmentMode.center, x: size.width/2, y: size.height/2 - 400, zPosition: 1, alpha: 0, scale: 1)
    }
    
    func setWaitingForOpponentLabel() {
        
        setLabel(label: waitingForOpponentLabel, text: "waiting for opponent", fontSize: 70, fontColor: SKColor.white, alignment: SKLabelHorizontalAlignmentMode.center, x: self.size.width/2, y: size.height/2 - 200, zPosition: 1, alpha: 1, scale: 0)
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
        readyLabel.run(fadeInAction)
    }
    
    func scrollBackground(currentTime: TimeInterval) {
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
    
    func startGame() {
        
        if (!single) {
            
            service.send(flag: "1")
            
            waitingTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        
            playerReady = true
        
            if enemyReady == true {
                
                readyToStart = true
            }
        } else {
            readyToStart = true
        }
        
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence)
        readyLabel.run(deleteSequence)
        
        

        
    }
    
    func runTimedCode() {
        if  waitingTimeLimit == 0 {
            waitingTimer.invalidate()
            currentGameState = gameState.afterGame
            self.removeAllActions()
            let changeSceneAction = SKAction.run(changeSceneMainMenu)
            self.run(changeSceneAction)
        } else {
            waitingTimeLimit -= 1
            let scaleDownAction = SKAction.scale(to: 0.7, duration: 0.5)
            let scaleUpAction = SKAction.scale(to: 1.5, duration: 0.5)
            let scaleSequence = SKAction.sequence([scaleUpAction, scaleDownAction])
            waitingForOpponentLabel.run(scaleSequence)
        }
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
        
        var randomNumber: Int = random(max:3)
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
        
        
        
        let moveCloud = SKAction.move(to: endPoint, duration: 1.9)
        let removeCloud = SKAction.removeFromParent()
        //let loseALifeAction = SKAction.run(loseALife)
        let cloudSequence = SKAction.sequence([moveCloud, removeCloud] )
        
        if currentGameState == gameState.inGame {
            clouds.append(cloud)
            cloud.run(cloudSequence, completion: {
                self.clouds.remove(at: self.clouds.index(of: cloud)!)
            })
            
        }
    }
    
    func findNearestCloud(plane: SKSpriteNode, clouds: [SKSpriteNode]) -> SKSpriteNode {
        var minDistance = findDistanceBetween(nodeA: plane, nodeB: clouds.first!)
        var indexOFClosest = 0
        for cloud in clouds {
            let candidate = findDistanceBetween(nodeA: plane, nodeB: cloud)
            if candidate < minDistance {
              minDistance = candidate
              indexOFClosest = clouds.index(of: cloud)!
            }
        }
        return clouds[indexOFClosest]
        
    }
    
    func findDistanceBetween(nodeA: SKSpriteNode, nodeB: SKSpriteNode) -> Float {
        let deltaX = nodeA.position.x - nodeB.position.x
        let deltaXSquare = deltaX * deltaX
        let deltaY = nodeA.position.y - nodeB.position.y
        let deltaYSquare = deltaY * deltaY
        let result = sqrt(deltaXSquare + deltaYSquare)
        return Float(result)
    }
    
    func startContactActions(contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == PhysicsCategories.Player && contact.bodyB.categoryBitMask == PhysicsCategories.Cloud {
            service.send(flag: "3")
            if contact.bodyA.node != nil {
                spawnExplosion(contact.bodyA.node!.position)
                winner = false
            }
            
            
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            
            runGameOver()
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
        let changeSceneAction = SKAction.run(changeSceneGameOver)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
    }
    
   
    
    func changeSceneGameOver() {
        
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
        
    }
    
    func changeSceneMainMenu() {
        
        let sceneToMoveTo = MainMenuScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
        
    }
    
    func addScore() {
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
    }
    
    
    
    //utility
    
    func initializeRandomNumberGenerator() {
        if !single {
            randomNumberGenerator = GKARC4RandomSource(seed: seed)
        } else {
            let date = Date()
            let calendar = Calendar.current
            let minute = calendar.component(.minute, from: date)
            var value = minute
            let data = withUnsafePointer(to: &value) {
                Data(bytes: UnsafePointer($0), count: MemoryLayout.size(ofValue: minute))
            }
            randomNumberGenerator = GKARC4RandomSource(seed: data)
        }
        randomNumberGenerator.dropValues(1024)
    }
    
    func random(max: Int) -> Int {
        
        return randomNumberGenerator.nextInt(upperBound:max)
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
                
            case "0":
    
                self.enemy.pokeToMove() //self.moveEnemyRight()
                
            case "1":
                
                self.enemyReady = true
                
                if self.playerReady {
                    self.readyToStart = true
                }
                
            case "3":
                
                self.spawnExplosion(self.enemy.node.position)
                self.enemy.node.removeFromParent()
                self.findNearestCloud(plane: self.enemy.node, clouds: self.clouds).removeFromParent()
                
                self.runGameOver()
                
            default:
                break
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
