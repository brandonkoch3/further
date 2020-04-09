//
//  CovidModel.swift
//  SwiftUIDesignProject
//
//  Created by Brandon on 4/2/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation

struct CovidModel: Codable, Equatable {
    var id: String
    var feelingSick: Bool
    var hasBeenTested: Bool
    var testResult: Bool
    var update: Double
}

struct CovidStory: Codable, Equatable, Identifiable {
    var id = UUID()
    var displayDate: String
    var dateGathered: Double
    var positiveContacts: [String]
    var didSendNotification: Bool
}
