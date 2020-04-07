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
    override var body: AnyView {
        return AnyView(ContentView().environmentObject(PersonDetectee()))
    }
}
