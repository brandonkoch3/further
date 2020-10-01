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
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: { userActivity in
                    
                    // Verify we truly have activity
                    guard userActivity.webpageURL != nil else {
                        return
                    }
                    
                    // Set that data is being shared
                    self.isSharingData = true
                    
                    // Parse the incoming URL
                    guard let incomingURL = userActivity.webpageURL,
                          let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true),
                          let queryItems = components.queryItems
                    else { return }
                    
                    // Set our received URL (for debug)
                    self.receivedURL = incomingURL.absoluteString
                    
                    print("Components:", components)
                    
                    // Get the path component
                    guard let path = components.path else { return }
                    
                    // Find the vendor ID, or exit
                    guard let vendorID = queryItems.first(where: { $0.name == "vendorID" }), let id = vendorID.value else {
                        return
                    }
                    environmentSettings.establishmentID = id
                    
                    // Find the vendor name, if it exists
                    if let vendorName = queryItems.first(where: { $0.name == "vendorName" }) {
                        if let name = vendorName.value {
                            environmentSettings.establishmentName = name.capitalized
                        }
                    }
                    
                    print("PATH:", path)
                    
                    // Handle configurations
                    switch path {
                        case "":
                            self.inRegion = true
                        case "/dine":
                            self.inRegion = true
                        case "/user/pair":
                            self.inRegion = true
                        case "/vendor/checkin":
                            self.inRegion = false
                        default:
                            break
                    }
                    
                    // Handle location check, as needed
                    guard !inRegion else { return }
                    if let payload = userActivity.appClipActivationPayload {
                        
                        // Get the coordinates, and display name, if they exist
                        guard let longitude = queryItems.first(where: { $0.name == "longitude" }),
                        let latitude = queryItems.first(where: { $0.name == "latitude" }),
                        let longitudeCoords = longitude.value,
                        let latitudeCoords = latitude.value,
                        let long = Double(longitudeCoords),
                        let lat = Double(latitudeCoords) else {
                            print("Problem")
                            return
                        }
                        
                        // Perform region check
                        locationAuthenticator.verify(payload: payload, longitude: long, latitude: lat, name: environmentSettings.establishmentName) { (inRegion, error) in
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
