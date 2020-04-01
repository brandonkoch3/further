//
//  PersonNotification.swift
//  SwiftUIDesignProject
//
//  Created by Brandon on 3/31/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation
import UserNotifications

class PersonNotifications {
    
    // Config
    private let userNotificationCenter = UNUserNotificationCenter.current()
    
    init() {
        self.requestNotificationAuthorization()
    }
    
    private func requestNotificationAuthorization() {
        let authOptions: UNAuthorizationOptions = [.alert, .sound]
        self.userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("Error: ", error)
            }
        }
    }
    
    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Someone Nearby!"
        content.body = "Someone has been detected nearby.  Please be aware of your surroundings and try to keep six feet from others."
        content.sound = UNNotificationSound.default
        let identifier = "Further Detection"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        self.userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Error:", error)
            }
        }
    }
    
}
