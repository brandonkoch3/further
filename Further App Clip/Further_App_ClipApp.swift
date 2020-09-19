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
    
    // MARK: UI Config
    @State private var inRegion = false
    @State private var establishmentName = "this establishment"
    
    // MARK: TEST
    @State private var receivedURL = ""
    
    var body: some Scene {
        WindowGroup {
            ContentView(isInRegion: $inRegion, establishmentName: $establishmentName, receivedURL: $receivedURL)
                .environmentObject(PersonInfoController())
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: { userActivity in
                    guard let url = userActivity.webpageURL else {
                        fatalError("BROKEN")
                    }
                    
                    guard let incomingURL = userActivity.webpageURL,
                          let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true),
                          let queryItems = components.queryItems
                    else { return }
                    
                    print("Components:", components)
                    
                    self.receivedURL = incomingURL.absoluteString
                    
                    // Get the path component
                    guard let path = components.path else { return }
                    
                    // Find the vendor ID, if it exists
                    if let vendorID = queryItems.first(where: { $0.name == "vendorID" }) {
                        print("The vendor id is", vendorID.value)
                    }
                    
                    // Handle configurations
                    switch path {
                        case "":
                            self.inRegion = true
                        case "/dine":
                            self.inRegion = true
                        default:
                            break
                    }
                    
                    print("Items:", queryItems)
                    
                    // Handle location check, as needed
                    guard !inRegion else { return }
                    if let payload = userActivity.appClipActivationPayload {
                        
                        // Get the coordinates, and display name, if they exist
                        guard let longitude = queryItems.first(where: { $0.name == "longitude" }),
                        let latitude = queryItems.first(where: { $0.name == "latitude" }),
                        let vendorName = queryItems.first(where: { $0.name == "vendorName" }),
                        let longitudeCoords = longitude.value,
                        let latitudeCoords = latitude.value,
                        let displayName = vendorName.value,
                        let long = Double(longitudeCoords),
                        let lat = Double(latitudeCoords) else {
                            print("Problem")
                            return
                        }
                        
                        print("Lat:", lat)
                        print("Lon:", long)
                        print("Name:", displayName)
                        
                        self.establishmentName = displayName.capitalized
                        
                        // Perform region check
                        locationAuthenticator.verify(payload: payload, longitude: long, latitude: lat, name: displayName) { (inRegion, error) in
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
