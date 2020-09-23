//
//  PersonInfoModel.swift
//  Futher
//
//  Created by Brandon on 9/10/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation
import SwiftUI

struct PersonInfoModel: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
    var phone: String {
        didSet {
            if phone.first != "+" {
                phone = phone.applyPatternOnNumbers(pattern: "(###) ###-####", replacmentCharacter: "#")
            }
        }
    }
    var address: String
    var unit: String
    var addressZip: String
}
