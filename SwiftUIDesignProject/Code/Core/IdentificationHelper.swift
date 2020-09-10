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
        self.locateUUID()
    }
    
    private func locateUUID() {
        
        if (WCSession.isSupported()) {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
        
        // iOS/iPadOS should check for ID from iCloud, then locally, or allow the newly generated one to be the default
        #if !os(watchOS)
        print("About to check for device ID from iCloud.")
        keyValStore.synchronize()
        if let myID = keyValStore.string(forKey: "deviceID") {
            self.myID = myID
            UserDefaults.standard.setValue(self.myID, forKey: "deviceID")
            print("Set device ID as", self.myID, "from iCloud.")
        } else if let myID = UserDefaults.standard.string(forKey: "deviceID") {
            self.myID = myID
            print("Set device ID as", self.myID, "from local storage.")
        } else {
            print("No device ID found.")
            self.myID = self.generateUUID()
            UserDefaults.standard.set(self.myID, forKey: "deviceID")
            keyValStore.set(self.myID, forKey: "deviceID")
            keyValStore.synchronize()
            print("Generated a new ID as", self.myID)
        }
        
        // watchOS should ask iPhone for ID - if it does not exist (I.E., an independent watchOS app), generate a new one
        #else
        print("Apple Watch is about to check for device ID.")
        if let myID = UserDefaults.standard.string(forKey: "deviceID") {
            self.myID = myID
            print("Set device ID as", myID, "from local storage.")
        }
        #endif
    }
    
    private func generateUUID() -> String {
        return UUID().uuidString
    }
}

extension IdentificationHelper: WCSessionDelegate {
    #if !os(watchOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        //
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //
    }
    #endif
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        #if !os(watchOS)
        print("watchOS activation session:", activationState.rawValue)
        #else
        guard self.myID == "" else { return }
        guard activationState == .activated else { return }
        print("Checking paired iPhone for device ID.")
        self.myID = self.generateUUID()
        UserDefaults.standard.set(self.myID, forKey: "deviceID")
        self.checkForLocalID() { response in
            if response {
                print("Received UUID from paired iPhone", self.myID)
            } else {
                self.myID = self.generateUUID()
                UserDefaults.standard.set(self.myID, forKey: "deviceID")
                print("Apple Watch generated a new UUID", self.myID, "and saved locally.")
            }
        }
        #endif
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        #if !os(watchOS)
        if let request = message["watchRequest"] as? Bool {
            if request {
                print("iPhone has received a request for device ID.")
                guard self.myID != "" else { return }
                let data: [String: Any] = ["foundUUID": self.myID]
                print("Sending response", data)
                replyHandler(data)
            }
        }
        #endif
    }
    
    private func checkForLocalID(completion: @escaping (Bool) -> Void) {
        guard self.myID == "" else { return }
        print("Apple Watch is about to request device ID.")
        if let validSession = self.session, validSession.isReachable {
            let data: [String: Any] = ["watchRequest": true]
            session?.sendMessage(data, replyHandler: { (response) in
                print("Apple Watch has received a response:", response)
                if let receivedID = response["foundUUID"] as? String {
                    self.myID = receivedID
                    UserDefaults.standard.set(self.myID, forKey: "deviceID")
                    completion(true)
                    return
                } else {
                    completion(false)
                    return
                }
            }, errorHandler: { (error) in
                completion(false)
                return
            })
        }
    }
}
