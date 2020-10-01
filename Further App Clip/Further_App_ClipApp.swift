//
//  Further_App_ClipApp.swift
//  Further App Clip
//
//  Created by Brandon on 9/17/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import SwiftUI
import AppClip

@main
struct Further_App_ClipApp: App {
    
    // MARK: Helpers
    let locationAuthenticator = LocationAuthenticator()
    var environmentSettings = EnvironmentSettings()
    var dataParser = DataParser()
    
    // MARK: UI Config
    @State private var inRegion = false
    
    // MARK: TEST
    @State private var receivedURL = ""
    @State private var isSharingData = false
    
    var body: some Scene {
        WindowGroup {
            ContentView(isInRegion: $inRegion, isSharingData: $isSharingData, receivedURL: $receivedURL)
                .environmentObject(PersonInfoController())
                .environmentObject(environmentSettings)
                .environmentObject(dataParser)
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: { userActivity in
                    
                    // Verify we truly have activity
                    guard userActivity.webpageURL != nil else {
                        return
                    }
                    
                    // Set that data is being shared
                    self.isSharingData = true
                    
                    // Parse the incoming URL
                    guard let incomingURL = userActivity.webpageURL else { return }
                    
                    // Parse URL
                    dataParser.setURL(url: incomingURL)
                    
                    // Set our received URL (for debug)
                    self.receivedURL = incomingURL.absoluteString
                    
                    // Handle configurations
                    switch dataParser.path {
                        case "":
                            self.inRegion = true
                        default:
                            break
                    }
                    
                    // Handle location check, as needed
                    guard !inRegion else { return }
                    if let payload = userActivity.appClipActivationPayload {
                        
                        // Set coordinates, if they exist
                        guard let longitude = dataParser.longitude,
                        let latitude = dataParser.latitude else {
                            return
                        }
                        
                        // Perform region check
                        locationAuthenticator.verify(payload: payload, longitude: longitude, latitude: latitude, name: dataParser.establishmentName) { (inRegion, error) in
                            if let e = error {
                                print("There was an error verifying region: ", e.localizedDescription)
                            }
                            self.inRegion = inRegion
                        }
                    }
                })
        }
    }
}
