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
import AVFoundation

class Haptics {
    
    // Config
    private var engine: CHHapticEngine?
    var player: CHHapticAdvancedPatternPlayer?
    @Published var allowed: Bool = true
    private var isPlaying = false
    
    // Audio
    private var soundEffect: AVAudioPlayer?
    
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
            .sink(receiveValue: { val in
                if val {
                    UserDefaults.standard.set(false, forKey: "disableHaptics")
                } else {
                    UserDefaults.standard.set(true, forKey: "disableHaptics")
                    self.cancelHaptics()
                }
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
        
        // Audio - This is omitted in 1.0.0.  We will introduce audio functionality with approved sound bytes in a later update.
//        let path = Bundle.main.path(forResource: "backup.m4a", ofType:nil)!
//        let url = URL(fileURLWithPath: path)
//        do {
//            self.soundEffect = try AVAudioPlayer(contentsOf: url)
//        } catch {
//            print("Audio error:", error)
//        }
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
        guard !self.isPlaying else { return }
        
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
            self.isPlaying = true
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
        
        // Omitted audio functionality
//        do {
//            self.soundEffect?.numberOfLoops = -1
//            self.soundEffect?.play()
//        }
    }
    
    func cancelHaptics() {
        guard self.isPlaying else { return }
        do {
            try self.player?.cancel()
            self.isPlaying = false
        } catch {
            print("Could not cancel haptic playback", error)
        }
        
        // Omitted audio functionality
//        do {
//            self.soundEffect?.stop()
//        }
    }
}
