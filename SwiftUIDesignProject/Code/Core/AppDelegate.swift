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
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.brandon.furtherBurstUpdate", using: nil) { (task) in
            self.handleAppBurstTask(task: task as! BGProcessingTask)
        }
        
        return true
    }
    
    func scheduleRefreshTask() {
        let refreshTask = BGProcessingTaskRequest(identifier: "com.brandon.furtherBurstUpdate")
        refreshTask.requiresExternalPower = false
        refreshTask.requiresNetworkConnectivity = true
        refreshTask.earliestBeginDate = Date(timeIntervalSinceNow: 60)
        do {
            try BGTaskScheduler.shared.submit(refreshTask)
            print("DEBUG -- Background task scheduled.")
        } catch {
            print("DEBUG -- Unable to schedule refresh task", error.localizedDescription)
        }
    }
    
    func handleAppBurstTask(task: BGProcessingTask) {
        let storiesController = StoriesController()
        storiesController.updateStories() { response in }
        print("DEBUG -- About to handle background task.")
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

