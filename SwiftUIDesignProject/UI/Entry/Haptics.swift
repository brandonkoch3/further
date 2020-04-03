//
//  Haptics.swift
//  SwiftUIDesignProject
//
//  Created by Brandon Koch on 3/30/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation
import CoreHaptics
import Combine

class Haptics {
    
    // Config
    private var engine: CHHapticEngine?
    var player: CHHapticAdvancedPatternPlayer?
    @Published var allowed: Bool = true
    
    // Combine
    var hapticSubscriber: AnyCancellable?
    
    // Lifecycle
    init() {
        prepareHaptics()
        
        if UserDefaults.standard.bool(forKey: "disableHaptics") {
            self.allowed = false
        }
        
        hapticSubscriber = $allowed
            .receive(on: RunLoop.main)
            .filter({ !$0 })
            .sink(receiveValue: { val in
                self.cancelHaptics()
            })
    }
    
    func prepareHaptics() {
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
    
    func intenseDetection() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        guard !UserDefaults.standard.bool(forKey: "disableHaptics") else { return }
        
        let short1 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0)
        let short2 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.2)
        let short3 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.4)
        let long1 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 0.6, duration: 0.5)
        let long2 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 1.2, duration: 0.5)
        let long3 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 1.8, duration: 0.5)
        let short4 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.4)
        let short5 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.6)
        let short6 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.8)

        do {
            let pattern = try CHHapticPattern(events: [short1, short2, short3, long1, long2, long3, short4, short5, short6], parameters: [])
            let player = try engine?.makeAdvancedPlayer(with: pattern)
            player?.loopEnabled = true
            self.player = player
            try self.player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
    
    func cancelHaptics() {
        do {
            try self.player?.cancel()
        } catch {
            print("Could not cancel haptic playback", error)
        }
    }
}
