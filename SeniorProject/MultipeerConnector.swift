//
//  MultipeerConnector.swift
//  MultipeerConn
//
//  Created by Baris Yagan on 3/22/17.
//  Copyright © 2017 Baris Yagan. All rights reserved.
//

import Foundation
import MultipeerConnectivity

var peerList = [MCPeerID]()
var seed = Data()
var opponentName = ""

class MultipeerConnector : NSObject {
    
    let serviceType = "mc-connector"
   
    let localID = MCPeerID(displayName: UIDevice.current.name)
    
    let advertiser: MCNearbyServiceAdvertiser
    
    let browser : MCNearbyServiceBrowser
    
    var delegate : MultipeerConnectorDelegate?
    
    var opponentPeerID : MCPeerID? = nil
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.localID, securityIdentity: nil, encryptionPreference: .none)
        
        session.delegate = self
        return session
    }()
    
    override init() {
        
        
        advertiser = MCNearbyServiceAdvertiser(peer: localID, discoveryInfo: nil, serviceType: serviceType)
        browser = MCNearbyServiceBrowser(peer: localID, serviceType: serviceType)
     
        super.init()
        
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        
        browser.delegate = self
        browser.startBrowsingForPeers()
        
                
    }
    
    deinit {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
        
        
    }
    
    func send(flag : String) {
        NSLog("%@", "sendFlag: \(flag) to \(session.connectedPeers.count) peers")
        
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(flag.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
        
    }
    
    /*func sendMinute(minute : String) {
        do {
            try self.session.send(minute.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
        }
        catch let error {
            NSLog("%@", "Error for sending: \(error)")
        }
 
    }*/
    
}

extension MultipeerConnector : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        if opponentPeerID != nil && peerID.displayName == opponentPeerID?.displayName {
            seed = context!
            invitationHandler(true, self.session)
            /*let date = Date()
            let calendar = Calendar.current
            let second = calendar.component(.second, from: date) + 3
            seed = String(second)
            send(flag: seed)*/
        }
        
    }
    
}

extension MultipeerConnector : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        if !peerList.contains(peerID) {
            peerList.append(peerID)
        }
        //NSLog("%@", "invitePeer: \(peerID)")
        //browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
        if peerList.contains(peerID) {
            peerList.remove(at: peerList.index(of: peerID)!)
        }
    }
    
}

extension MultipeerConnector : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state)")
        readyToMoveOn = true
        opponentName = peerID.displayName
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        let str = String(data: data, encoding: .utf8)!
        self.delegate?.numberChanged(manager: self, numberString: str)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
    
}

extension MultipeerConnector: MultiplayerPeerDelegate {
    func inviteP(peerID: MCPeerID) {
        self.opponentPeerID = peerID
        
        let minute = getMinute()
        let data = fromIntToData(minute: minute)
        //print("zzzzzzszzzzszszszszz")
        /*let date = Date()
        let calendar = Calendar.current
        let minute = calendar.component(.minute, from: date)*/
        //String(minute).data(using: .utf8)
        seed = data
        browser.invitePeer(peerID, to: self.session, withContext: data, timeout: 10)
        
        
    }
    
    func getMinute() -> Int {
        let date = Date()
        let calendar = Calendar.current
        let minute = calendar.component(.minute, from: date)
        return minute
    }
    
    func fromIntToData (minute: Int) -> Data{
        var value = minute
        let data = withUnsafePointer(to: &value) {
            Data(bytes: UnsafePointer($0), count: MemoryLayout.size(ofValue: minute))
        }
        return data
    }
}

protocol MultipeerConnectorDelegate {
    
    func connectedDevicesChanged(manager : MultipeerConnector, connectedDevices: [String])
    
    func numberChanged(manager : MultipeerConnector, numberString: String)
    
   // func minuteSend(minute: String)
    
}
