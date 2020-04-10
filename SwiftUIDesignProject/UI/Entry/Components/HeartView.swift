////
////  HeartView.swift
////  SwiftUIDesignProject
////
////  Created by Brandon on 4/9/20.
////  Copyright © 2020 Brandon. All rights reserved.
////
//
//import Foundation
//import SwiftUI
//
//struct HeartView: View {
//    
//    // UI Config
//    @Environment(\.colorScheme) var colorScheme
//    @State private var pulsate = false
//    
//    // Person Config
//    @ObservedObject var detector: PersonDetectee
//    
//    // View
//    var body: some View {
//        ZStack {
//            Image(colorScheme == .light ? "light_heart_background" : "dark_heart_background")
//                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
//                .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
//            Image(colorScheme == .light ? "light_\(self.detector.personFound ? "on" : "off")_heart" : "dark_\(self.detector.personFound ? "on" : "off")_heart")
//            .scaleEffect(pulsate ? 0.5 : 1)
//                .animation(Animation.easeInOut(duration: 1).delay(0).repeat(while: pulsate))
//                .onAppear() {
//                    self.pulsate.toggle()
//                    print("COLOR SCHEME:", self.colorScheme)
//                }
//        }
//    }
//}
//
//struct HeartView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            HeartView(detector: PersonDetectee())
//                .environmentObject(EnvironmentSettings())
//                .environment(\.colorScheme, .light)
//                .previewDevice("iPhone 11 Pro Max")
//            
//            HeartView(detector: PersonDetectee())
//                .environmentObject(EnvironmentSettings())
//                .environment(\.colorScheme, .light)
//                .previewDevice("iPhone SE")
//        }
//        
//    }
//}
