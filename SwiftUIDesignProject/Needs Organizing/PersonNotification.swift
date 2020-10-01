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
        content.title = "Updated Interactions Are Available"
        content.body = "We've updated your app to determine if any nearby interactions have reported feeling under the weather."
        content.sound = UNNotificationSound.default
        let identifier = "Further - Updated Interactions"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        self.userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Error:", error)
            }
        }
    }
    
}
