//
//  LocationAuthenticator.swift
//  Further App Clip
//
//  Created by Brandon on 9/17/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation
import AppClip
import CoreLocation

struct LocationAuthenticator {
    
    public func verify(payload: APActivationPayload, longitude: Double, latitude: Double, name: String, completion: @escaping (Bool, Error?) -> Void) {
        let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), radius: 100, identifier: name)
        print("Region:", region)
        payload.confirmAcquired(in: region) { (inRegion, error) in
            print("In region:", inRegion)
            if let error = error {
                completion(false, error)
                return
            }
            completion(inRegion, nil)
        }
    }
}
