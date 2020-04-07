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
    @State private var pulsate = false
    @EnvironmentObject var detector: PersonDetectee
    
    var body: some View {
        VStack {
            VStack {
                if detector.personFound {
                    PersonButton(pulsate: $pulsate)
                        .buttonStyle(DarkButtonStyle())
                        .environmentObject(detector)
                    Text("Someone Is Nearby!")
                        .foregroundColor(.offWhite)
                        .bold()
                } else {
                    SearchButton(pulsate: $pulsate)
                        .buttonStyle(DarkButtonStyle())
                        .environmentObject(detector)
                        .padding()
                    Text("Searching")
                        .foregroundColor(.offWhite)
                        .bold()
                }
            }
            Spacer()
            HStack {
                Image(systemName: "list.dash")
                .foregroundColor(Color.gray)
                .font(.system(size: 18, weight: .regular))
                Spacer()
                Image(systemName: "person.3")
                .foregroundColor(Color.gray)
                .font(.system(size: 18, weight: .regular))
            }
        }.onAppear(perform: {
            print("HELLO")
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(PersonDetectee())
    }
}

struct SearchButton: View {
    @Binding var pulsate: Bool
    @EnvironmentObject var detector: PersonDetectee
    var body: some View {
        Button(action: {
            self.pulsate.toggle()
            self.detector.isDetecting.toggle()
        }) {
            Image(systemName: detector.isDetecting ? "heart.fill" : "heart.slash.fill")
                .foregroundColor(.gray)
                .font(.system(size: 50, weight: .ultraLight))
                .scaleEffect(pulsate ? 0.5 : 1)
                .animation(Animation.easeInOut(duration: 1).delay(0).repeat(while: pulsate))
                .onAppear() {
                    self.pulsate.toggle()
            }
        }
    }
}

struct PersonButton: View {
    @Binding var pulsate: Bool
    @EnvironmentObject var detector: PersonDetectee
    var body: some View {
        Button(action: {
            self.pulsate.toggle()
            self.detector.isDetecting.toggle()
        }) {
            Image(systemName: detector.isDetecting ? "exclamationmark.triangle.fill" : "heart.slash.fill")
                .foregroundColor(detector.isDetecting ? .red : .gray)
                .font(.system(size: 50, weight: .ultraLight))
                .scaleEffect(pulsate ? 0.5 : 1)
                .animation(Animation.easeInOut(duration: 1).delay(0).repeat(while: detector.isDetecting))
                .onAppear() {
                    self.pulsate.toggle()
            }
        }
    }
}
