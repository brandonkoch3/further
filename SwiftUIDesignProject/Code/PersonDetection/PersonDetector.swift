//
//  PersonDetector.swift
//  SwiftUIDesignProject
//
//  Created by Brandon on 3/29/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation
import SwiftUI
import MultipeerConnectivity
import Combine

class PersonDetector: NSObject, ObservableObject {
    
    // Config
    private let serviceType = "socialdistancer"
    public var myID: String!
    private var myPeerID: MCPeerID!
    
    // Updateable config
    @Published var personFound = false
    @Published var isDetecting = false
    
    // Multipeer Config
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    private var session: MCSession!
    
    // Participants
    @Published var activeParticipants = [PersonModel]()
    private var savedParticipants = [PersonModel]()
    
    // Combine
    var participantCancellable: AnyCancellable?
    var detectingCancellable: AnyCancellable?
    var backgroundExecution: Bool = false
    
    // Helpers
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let defaults = UserDefaults.standard
    let notifications = PersonNotifications()
    
    init(backgroundExecution: Bool? = false) {
        if let myID = UserDefaults.standard.string(forKey: "deviceID") {
            self.myID = myID
        } else {
            let newID = UUID().uuidString
            self.myID = newID
            UserDefaults.standard.set(newID, forKey: "deviceID")
        }
        self.myPeerID = MCPeerID(displayName: self.myID)
        if let backgroundStatus = backgroundExecution {
            self.backgroundExecution = backgroundStatus
        }
        
        if !self.backgroundExecution {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: self.myPeerID, discoveryInfo: nil, serviceType: serviceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: self.myPeerID, serviceType: serviceType)
        self.session = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: .required)
        
        super.init()
        self.serviceAdvertiser.delegate = self
        self.serviceBrowser.delegate = self
        self.session.delegate = self
        
        if let savedData = defaults.object(forKey: "interactions") as? Data {
            if let loadedData = try? decoder.decode([PersonModel].self, from: savedData) {
                self.savedParticipants = loadedData
            }
        }
        
        participantCancellable = $activeParticipants
            .receive(on: RunLoop.main)
            .sink(receiveValue: { participants in
                if !self.backgroundExecution {
                    self.personFound = (participants.count > 0)
                } else {
                    if participants.count > 0 {
                        self.notifications.sendNotification()
                    }
                }
            })
        
        self.isDetecting = true
        
        detectingCancellable = $isDetecting
        .receive(on: RunLoop.main)
        .sink(receiveValue: { detecting in
            print("DETECTING?", detecting)
            detecting ? self.start() : self.stop()
        })
    
    }
    
    func start() {
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    func stop() {
        self.session.disconnect()
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
        self.activeParticipants.removeAll()
    }
    
    func peerConnected(peerID: MCPeerID) {
        guard !self.activeParticipants.contains(where: { $0.personUUID == peerID.displayName }) else { return }
        guard !self.savedParticipants.contains(where: { $0.personUUID == peerID.displayName && $0.hasReceivedNotification }) else { return }
        let newParticipant = PersonModel(personUUID: peerID.displayName, bleUUID: nil, connectTime: Date().timeIntervalSince1970, disconnectTime: nil, hasReceivedNotification: false)
        print("Connected to", peerID.displayName)
        DispatchQueue.main.async {
            self.activeParticipants.append(newParticipant)
        }
    }
    
    func peerDisconnected(peerID: MCPeerID) {
        guard self.activeParticipants.contains(where: { $0.personUUID == peerID.displayName }) else { return }
        if let participant = self.activeParticipants.first(where: { $0.personUUID == peerID.displayName }) {
            var myParticipant = participant
            if Date().timeIntervalSince1970 - myParticipant.connectTime >= 60 {
                myParticipant.disconnectTime = Date().timeIntervalSince1970
                print("Disconnected from", peerID.displayName, "with 60 second interval")
                self.save(participant: myParticipant)
            }
            DispatchQueue.main.async {
                self.activeParticipants.removeAll(where: { $0.personUUID == peerID.displayName })
            }
            print("Disconnected from", peerID.displayName)
        }
    }
    
    func save(participant: PersonModel) {
        self.savedParticipants.append(participant)
        if let encoded = try? encoder.encode(self.savedParticipants) {
            defaults.set(encoded, forKey: "interactions")
        }
    }
}

extension PersonDetector: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.session)
        print("RECEIVED INVITATION FROM:", peerID)
    }
}

extension PersonDetector: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("FOUND PEER")
        guard !self.activeParticipants.contains(where: { $0.personUUID == peerID.displayName }), peerID.displayName != self.myID else { return }
        print("INVITING:", peerID)
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        peerDisconnected(peerID: peerID)
    }
}

extension PersonDetector: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            peerConnected(peerID: peerID)
        case .connecting:
            print("ATTEMPTING TO CONNECT")
        case .notConnected:
            peerDisconnected(peerID: peerID)
        @unknown default:
            break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        //
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        //
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        //
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        //
    }
}


