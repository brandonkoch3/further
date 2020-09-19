//
//  FurtherLogger.swift
//  Futher
//
//  Created by Brandon on 9/17/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation
import os.log

final class FurtherLogger {
    var logger: Logger
    
    init(category: String) {
        logger = Logger(subsystem: "com.bnbmedia.further", category: category)
    }
}
