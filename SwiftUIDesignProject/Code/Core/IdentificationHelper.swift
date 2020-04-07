//
//  IdentificationHelper.swift
//  SwiftUIDesignProject
//
//  Created by Brandon Koch on 4/7/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation
import WatchConnectivity
import Combine

class IdentificationHelper: NSObject, ObservableObject {
    
    // Config
    @Published var myID: String = ""
    
    // Helpers
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let defaults = UserDefaults.standard
    var session: WCSession?
    
    #if !os(watchOS)
    var keyValStore = NSUbiquitousKeyValueStore()
    #endif
    
    // Lifecycle
    override init() {
        
        super.init()
        
        // iOS/iPadOS should check for ID from iCloud, then locally, or allow the newly generated one to be the default
        #if !os(watchOS)
        if let myID = keyValStore.string(forKey: "deviceID") {
            self.myID = myID
        } else if let myID = UserDefaults.standard.string(forKey: "deviceID") {
            self.myID = myID
        } else {
            self.myID = self.generateUUID()
            UserDefaults.standard.set(self.myID, forKey: "deviceID")
            keyValStore.set(self.myID, forKey: "deviceID")
            keyValStore.synchronize()
        }
        
        // watchOS should ask iPhone for ID - if it does not exist (I.E., an independent watchOS app), generate a new one
        #else
        if let myID = UserDefaults.standard.string(forKey: "deviceID") {
            self.myID = myID
        } else {
            
            self.checkForLocalID() { response in
                if let localUUID = response {
                    
                } else {
                    self.myID = self.generateUUID()
                    UserDefaults.standard.set(self.myID, forKey: "deviceID")
                }
            }
        }
        #endif
    }
    
    private func locateUUID() {
        
    }
    
    private func generateUUID() -> String {
        return UUID().uuidString
    }
}

extension IdentificationHelper: WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        //
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        #if os(watchOS)
        if let myUUID = message["foundUUID"] as? String {
            self.myID = myUUID
        }
        #else
        if let request = message["watchRequest"] as? Bool {
            if request {
                guard self.myID != "" else { return }
                let data: [String: Any] = ["foundUUID": self.myID]
                
            }
        }
        #endif
    }
    
    private func checkForLocalID(completion: @escaping (Bool) -> Void) {
        guard self.myID == "" else { return }
        if let validSession = self.session, validSession.isReachable {
            let data: [String: Any] = ["watchRequest": true]
            
        }
    }
    
    private func sendUUIDToWatch() {
        
    }
}
