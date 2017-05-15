//
//  MultiplayerPeerSceneTests.swift
//  SeniorProject
//
//  Created by Baris Yagan on 5/14/17.
//  Copyright © 2017 Baris Yagan. All rights reserved.
//

import XCTest
import MultipeerConnectivity
import SpriteKit

@testable import SeniorProject

class MultiplayerPeerSceneTests: XCTestCase {
    
    var mpc: MultiplayerPeerScene!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        mpc = MultiplayerPeerScene(size: CGSize(width: 1080, height: 1920))
        
        mpc.player1.text = "<<empty>>"
        mpc.playerList.append(mpc.player1)
        
        mpc.player2.text = "<<empty>>"
        mpc.playerList.append(mpc.player2)
        
        mpc.player3.text = "<<empty>>"
        mpc.playerList.append(mpc.player3)
        
        mpc.player4.text = "<<empty>>"
        mpc.playerList.append(mpc.player4)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        mpc = nil
        peerList.removeAll()
        
        super.tearDown()
    }
    
    func testUpdatePlayerLabelsEmpty() {
        
        let newPeer1 = MCPeerID(displayName: "new1")
        let newPeer2 = MCPeerID(displayName: "new2")
        
        peerList.append(newPeer1)
        peerList.append(newPeer2)
        
        mpc.updatePlayerLabels()
        
        XCTAssertEqual(mpc.playerList[0].text, "new1")
        XCTAssertEqual(mpc.playerList[1].text, "new2")
        XCTAssertEqual(mpc.playerList[2].text, "<<empty>>")
        XCTAssertEqual(mpc.playerList[3].text, "<<empty>>")
    }
    
    func testUpdatePlayerLabelsFoundPeer() {
        
        let newPeer1 = MCPeerID(displayName: "new1")
        let newPeer2 = MCPeerID(displayName: "new2")
        let newPeer3 = MCPeerID(displayName: "new3")
        
        peerList.append(newPeer1)
        peerList.append(newPeer2)
        
        mpc.updatePlayerLabels()
        
        peerList.append(newPeer3)
        
        mpc.updatePlayerLabels()
        
        XCTAssertEqual(mpc.playerList[0].text, "new1")
        XCTAssertEqual(mpc.playerList[1].text, "new2")
        XCTAssertEqual(mpc.playerList[2].text, "new3")
        XCTAssertEqual(mpc.playerList[3].text, "<<empty>>")
    }
    
    func testUpdatePlayerLabelsLostLastPeer() {
        
        let newPeer1 = MCPeerID(displayName: "new1")
        let newPeer2 = MCPeerID(displayName: "new2")
        let newPeer3 = MCPeerID(displayName: "new3")
        
        peerList.append(newPeer1)
        peerList.append(newPeer2)
        peerList.append(newPeer3)
        
        mpc.updatePlayerLabels()
        
        peerList.removeLast()
        
        mpc.updatePlayerLabels()
        
        XCTAssertEqual(mpc.playerList[0].text, "new1")
        XCTAssertEqual(mpc.playerList[1].text, "new2")
        XCTAssertEqual(mpc.playerList[2].text, "<<empty>>")
        XCTAssertEqual(mpc.playerList[3].text, "<<empty>>")
    }
    
    func testUpdatePlayerLabelsLostMiddlePeer() {
        
        let newPeer1 = MCPeerID(displayName: "new1")
        let newPeer2 = MCPeerID(displayName: "new2")
        let newPeer3 = MCPeerID(displayName: "new3")
        
        peerList.append(newPeer1)
        peerList.append(newPeer2)
        peerList.append(newPeer3)
        
        mpc.updatePlayerLabels()
        
        peerList.remove(at: 1)
        
        mpc.updatePlayerLabels()
        
        XCTAssertEqual(mpc.playerList[0].text, "new1")
        XCTAssertEqual(mpc.playerList[1].text, "new3")
        XCTAssertEqual(mpc.playerList[2].text, "<<empty>>")
        XCTAssertEqual(mpc.playerList[3].text, "<<empty>>")
    }
    
    func testUpdatePlayerLabelsLostFirstTwoPeer() {
        
        let newPeer1 = MCPeerID(displayName: "new1")
        let newPeer2 = MCPeerID(displayName: "new2")
        let newPeer3 = MCPeerID(displayName: "new3")
        
        peerList.append(newPeer1)
        peerList.append(newPeer2)
        peerList.append(newPeer3)
        
        mpc.updatePlayerLabels()
        
        peerList.remove(at: 0)
        peerList.remove(at: 0)

        
        mpc.updatePlayerLabels()
        
        XCTAssertEqual(mpc.playerList[0].text, "new3")
        XCTAssertEqual(mpc.playerList[1].text, "<<empty>>")
        XCTAssertEqual(mpc.playerList[2].text, "<<empty>>")
        XCTAssertEqual(mpc.playerList[3].text, "<<empty>>")
    }
    
    func testUpdatePlayerLabelsLostLastTwoPeer() {
        
        let newPeer1 = MCPeerID(displayName: "new1")
        let newPeer2 = MCPeerID(displayName: "new2")
        let newPeer3 = MCPeerID(displayName: "new3")
        
        peerList.append(newPeer1)
        peerList.append(newPeer2)
        peerList.append(newPeer3)
        
        mpc.updatePlayerLabels()
        
        peerList.remove(at: 2)
        peerList.remove(at: 1)
        
        
        mpc.updatePlayerLabels()
        
        XCTAssertEqual(mpc.playerList[0].text, "new1")
        XCTAssertEqual(mpc.playerList[1].text, "<<empty>>")
        XCTAssertEqual(mpc.playerList[2].text, "<<empty>>")
        XCTAssertEqual(mpc.playerList[3].text, "<<empty>>")
    }
    
    func testUpdatePlayerLabelsLostAllPeer() {
        
        let newPeer1 = MCPeerID(displayName: "new1")
        let newPeer2 = MCPeerID(displayName: "new2")
        let newPeer3 = MCPeerID(displayName: "new3")
        
        peerList.append(newPeer1)
        peerList.append(newPeer2)
        peerList.append(newPeer3)
        
        mpc.updatePlayerLabels()
        
        peerList.remove(at: 2)
        peerList.remove(at: 1)
        peerList.remove(at: 0)
        
        
        mpc.updatePlayerLabels()
        
        XCTAssertEqual(mpc.playerList[0].text, "<<empty>>")
        XCTAssertEqual(mpc.playerList[1].text, "<<empty>>")
        XCTAssertEqual(mpc.playerList[2].text, "<<empty>>")
        XCTAssertEqual(mpc.playerList[3].text, "<<empty>>")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
