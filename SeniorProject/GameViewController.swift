//
//  GameViewController.swift
//  SeniorProject
//
//  Created by Baris Yagan on 11/29/16.
//  Copyright © 2016 Baris Yagan. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation
import MultipeerConnectivity


class GameViewController: UIViewController {

    var backingAudio = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filePath = Bundle.main.path(forResource: "gameSound", ofType: "mp3")
        let audioNSURL = URL(fileURLWithPath: filePath!)
        
        do {
            backingAudio = try AVAudioPlayer(contentsOf: audioNSURL)
        } catch {
            return print("Cannot Find The Audio")
        }
        
        backingAudio.numberOfLoops = -1
        backingAudio.play()
        
      
        
        
        
        let scene = MainMenuScene(size: CGSize(width: 1080, height: 1920))
        
        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .aspectFill
        
        skView.presentScene(scene)
        
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
