//
//  HostingController.swift
//  Further Extension
//
//  Created by Brandon Koch on 4/6/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<AnyView> {
    var detector = PersonDetectee()
    var environmentSettings = EnvironmentSettings()
    override var body: AnyView {
        return AnyView(EntryView()
            .environmentObject(detector)
            .environmentObject(environmentSettings)
        )
    }
}