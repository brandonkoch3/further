//
//  NetworkingHelper.swift
//  SwiftUIDesignProject
//
//  Created by Brandon Koch on 3/30/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation
import Network
import SwiftUI

class NetworkHelper: ObservableObject {
    
    // UI Components
    @Published var isWifiConnected = false
    let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    
    init() {
        checkWifiStatus()
    }
    
    func checkWifiStatus() {
        guard !UserDefaults.standard.bool(forKey: "sawWifiAlert") else { return }
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.isWifiConnected = true
            } else {
                self.isWifiConnected = false
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    func stopWifiCheck() {
        monitor.cancel()
    }
}
