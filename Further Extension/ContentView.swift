//
//  ContentView.swift
//  Further Extension
//
//  Created by Brandon Koch on 4/6/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    // UI Config
    @EnvironmentObject var detector: PersonDetectee
    
    // Environment/Features
    @EnvironmentObject var environmentSettings: EnvironmentSettings
    
    var body: some View {
        VStack {
            Image("dark_on_heart@3x.png")
            Text("Test")
        }.background(Color.red)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PersonDetectee()) 
            .environmentObject(EnvironmentSettings())
    }
}
