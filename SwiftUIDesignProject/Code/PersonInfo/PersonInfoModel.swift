//
//  PersonInfoModel.swift
//  Futher
//
//  Created by Brandon on 9/10/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation

struct PersonInfoModel: Identifiable, Codable {
    var id: String
    var name: String?
    var email: String?
    var phone: String?
    var address: String?
    var qrCodePath: URL?
}
