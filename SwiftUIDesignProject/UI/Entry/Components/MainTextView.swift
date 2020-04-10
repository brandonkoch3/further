////
////  MainTextView.swift
////  SwiftUIDesignProject
////
////  Created by Brandon on 4/9/20.
////  Copyright © 2020 Brandon. All rights reserved.
////
//
//import SwiftUI
//
//struct MainTextView: View {
//    
//    // UI Config
//    @Environment(\.colorScheme) var colorScheme
//    
//    // Person Config
//    @ObservedObject var detector: PersonDetectee
//    
//    // View
//    var body: some View {
//        Text(detector.personFound ? "Someone is nearby!" : "Checking for others")
//            .font(Font.custom("Rubik-Regular", size: 26.67))
//            .foregroundColor(Color(hex: "323653"))
//    }
//}
//
//struct MainTextView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            MainTextView(detector: PersonDetectee())
//                .environmentObject(EnvironmentSettings())
//                .environment(\.colorScheme, .light)
//                .previewDevice("iPhone 11 Pro Max")
//            
//            MainTextView(detector: PersonDetectee())
//                .environmentObject(EnvironmentSettings())
//                .environment(\.colorScheme, .light)
//                .previewDevice("iPhone SE")
//        }
//        
//    }
//}
