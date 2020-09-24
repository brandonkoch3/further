//
//  EnvironmentSettings.swift
//  SwiftUIDesignProject
//
//  Created by Brandon on 4/3/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class EnvironmentSettings: ObservableObject {
    
    // MARK: Config
    enum appType: Int, Codable {
        case user
        case establishmentClient
        case establishmentKiosk
        case cityEntity
        case unknown
    }
    
    // MARK: App Type
    #if APPCLIP
    @AppStorage("appType", store: UserDefaults(suiteName: "group.com.bnbmedia.further.contents")) var appType: appType = .user
    #else
    @AppStorage("appType", store: UserDefaults(suiteName: "group.com.bnbmedia.further.contents")) var appType: appType = .unknown
    #endif
    
    // MARK: API
    @AppStorage("baseURL", store: UserDefaults(suiteName: "group.com.bnbmedia.further.contents")) var baseURL: String = "https://further-app.com/connect/"
    
    init() {
        baseURL = "https://further-app.com/connect/"
    }
}
