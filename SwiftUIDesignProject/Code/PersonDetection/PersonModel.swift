//
//  PersonModel.swift
//  SwiftUIDesignProject
//
//  Created by Brandon Koch on 3/29/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation

struct PersonModel: Codable {
    var personUUID: String
    var bleUUID: String?
    var connectTime: Double
    var disconnectTime: Double?
    var hasReceivedNotification: Bool
}

