//
//  Haptics.swift
//  SwiftUIDesignProject
//
//  Created by Brandon Koch on 3/30/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation
import CoreHaptics

struct Haptics {
    
    private var engine: CHHapticEngine?
    
    init() {
        prepareHaptics()
    }
    
    mutating func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            self.engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Could not start haptic engine:", error.localizedDescription)
        }
    }
    
    func detectedHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic pattern:", error.localizedDescription)
        }
    }
}
