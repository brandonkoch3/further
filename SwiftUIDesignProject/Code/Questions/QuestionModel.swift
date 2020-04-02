//
//  QuestionModel.swift
//  SwiftUIDesignProject
//
//  Created by Brandon on 4/1/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation
struct QuestionModel: Codable, Equatable, Identifiable {
    var id = UUID()
    var sectionHeader: String
    var question: [Question]
}

struct Question: Codable, Equatable, Identifiable {
    var id = UUID()
    var text: String
    var response: Bool
}
