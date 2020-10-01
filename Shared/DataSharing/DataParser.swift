//
//  DataParser.swift
//  Further
//
//  Created by Brandon on 10/1/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation

class DataParser: ObservableObject {
    
    // MARK: Config
    private var url: URL?
    
    // MARK: Parameters
    @Published var path: String?
    @Published var vendorID: String?
    @Published var establishmentName = "this establishment"
    @Published var longitude: Double?
    @Published var latitude: Double?
    
    init() {
    }
    
    // MARK: Config
    public func setURL(url: URL) {
        self.url = url
        self.parse()
    }
    
    // MARK: Parse
    private func parse() {
        guard let providedURL = url else { return }
        guard let components = NSURLComponents(url: providedURL, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems
        else { return }
        self.path = components.path
        
        guard let vendorID = queryItems.first(where: { $0.name == "vendorID" }), let id = vendorID.value else {
            return
        }
        self.vendorID = id
        
        if let vendorName = queryItems.first(where: { $0.name == "vendorName" }) {
            if let name = vendorName.value {
                self.establishmentName = name
            }
        }
        
        guard let longitude = queryItems.first(where: { $0.name == "longitude" }),
        let latitude = queryItems.first(where: { $0.name == "latitude" }),
        let longitudeCoords = longitude.value,
        let latitudeCoords = latitude.value,
        let long = Double(longitudeCoords),
        let lat = Double(latitudeCoords) else {
            return
        }
        self.longitude = long
        self.latitude = lat
        
    }
}
