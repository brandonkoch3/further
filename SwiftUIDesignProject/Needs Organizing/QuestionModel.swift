//
//  QuestionModel.swift
//  SwiftUIDesignProject
//
//  Created by Brandon on 4/1/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation
struct QuestionModel: Codable, Equatable, Identifiable {
    var id: Int
    var sectionHeader: String
    var questions: [Question]
}

struct Question: Codable, Equatable, Identifiable {
    var id: Int
    var icon: String
    var headline: String
    var subtitle: String
    var response: Bool
}
