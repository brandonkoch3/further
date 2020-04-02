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

/*
 
 - Once a day, GET list of results from server
    - Results: List of UUID that have positive test result and updated within last 14 days
    - Determine if any locally saved (and not yet notified) UUIDs are on that list
    - If yes, determine number
        - > 5 = red warning
        - <= 5 = yellow warning
        - 0 = green check mark
    - If yes, mark "notified" to locally saved results
    - Trigger User Notification if not in app to show that a new result is avaiable
    - Add to COVID STORY and display in UI
 
 */
