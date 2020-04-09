//
//  AppDelegate.swift
//  SwiftUIDesignProject
//
//  Created by Brandon on 3/17/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import UIKit
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.bnbmedia.furtherBurstUpdate", using: nil) { (task) in
            self.handleAppBurstTask(task: task as! BGProcessingTask)
        }
        
        return true
    }
    
    func scheduleRefreshTask() {
        let refreshTask = BGProcessingTaskRequest(identifier: "com.bnbmedia.furtherBurstUpdate")
        refreshTask.requiresExternalPower = false
        refreshTask.requiresNetworkConnectivity = true
        
        let now = Date()
        guard let then = Date().checkDate() else { return }
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([Calendar.Component.second], from: now, to: then)
        let seconds = dateComponents.second
        guard let diff = seconds, diff >= 0 else { return }
        
        refreshTask.earliestBeginDate = Date(timeIntervalSinceNow: TimeInterval(diff))
        do {
            try BGTaskScheduler.shared.submit(refreshTask)
        } catch {
            print("DEBUG -- Unable to schedule refresh task", error.localizedDescription)
        }
    }
    
    func handleAppBurstTask(task: BGProcessingTask) {
        let storiesController = StoriesController()
        storiesController.update() { response in }
        task.expirationHandler = {
            self.scheduleRefreshTask()
            DispatchQueue.main.async {
                task.setTaskCompleted(success: true)
            }
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

