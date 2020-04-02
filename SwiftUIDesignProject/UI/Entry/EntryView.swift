//
//  EntryView.swift
//  SwiftUIDesignProject
//
//  Created by Brandon on 3/17/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import SwiftUI
import Combine
import UIKit

struct EntryView: View {
    
    // UI Config
    @Environment(\.colorScheme) var colorScheme
    @State private var pulsate = false
    @State var showingQuestionSheet = false
    private var haptics = Haptics()
    
    // Detector config
    @EnvironmentObject var detector: PersonDetectee
    @ObservedObject var network = NetworkHelper()
    
    var body: some View {
        ZStack {
            if colorScheme == .dark {
                LinearGradient(Color.darkStart, Color.darkEnd)
            } else {
                Color.offWhite
            }
            VStack {
                Spacer()
                VStack {
                    if detector.personFound {
                        if colorScheme == .dark {
                            PersonButton(pulsate: $pulsate)
                                .onAppear(perform: haptics.detectedHaptics)
                                .buttonStyle(DarkButtonStyle())
                        } else {
                            PersonButton(pulsate: $pulsate)
                                .onAppear(perform: haptics.detectedHaptics)
                                .buttonStyle(LightButtonStyle())
                        }
                        Text("Someone Is Nearby!")
                            .foregroundColor(colorScheme == .dark ? .offWhite : .lairDarkGray)
                            .bold()
                    } else {
                        if colorScheme == .dark {
                            SearchButton(pulsate: $pulsate)
                                .buttonStyle(DarkButtonStyle())
                        } else {
                            SearchButton(pulsate: $pulsate)
                                .buttonStyle(LightButtonStyle())
                        }
                        Text(detector.isDetecting ? "Checking For Others" : "Paused")
                            .foregroundColor(colorScheme == .dark ? .offWhite : .lairDarkGray)
                            .bold()
                    }
                }
                Spacer()
                HStack {
                    if colorScheme == .dark {
                        QuestionButton(showingQuestionSheet: $showingQuestionSheet, userID: self.detector.myID)
                        Spacer()
                        CameraButton()
                        
                    } else {
                        QuestionButton(showingQuestionSheet: $showingQuestionSheet, userID: self.detector.myID)
                        Spacer()
                        CameraButton()
                    }
                }
            }.padding()
        }
        .alert(isPresented: $network.isWifiConnected) {
            Alert(title: Text("Disable Wifi"), message: Text("For best performance, we suggest disconnecting from your Wi-Fi network.  Wi-Fi can result in inaccurate distance calculations."), dismissButton: .default(Text("Dismiss")) {
                    UserDefaults.standard.set(true, forKey: "sawWifiAlert")
                    self.network.stopWifiCheck()
                })
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct EntryView_Previews: PreviewProvider {
    static var previews: some View {
        EntryView()
            .environmentObject(PersonDetectee())
            .environment(\.colorScheme, .light)
    }
}

struct QuestionButton: View {
    @Binding var showingQuestionSheet: Bool
    var userID: String
    var body: some View {
        Button(action: {
            self.showingQuestionSheet.toggle()
        }) {
            Image(systemName: "list.dash")
                .foregroundColor(.gray)
                .font(.system(size: 30, weight: .regular))
        }.sheet(isPresented: $showingQuestionSheet) {
            QuestionView(showingQuestionSheet: self.$showingQuestionSheet)
        }.padding()
    }
}

struct CameraButton: View {
    var body: some View {
        Button(action: {
            //
        }) {
            Image(systemName: "camera.fill")
                .foregroundColor(.gray)
                .font(.system(size: 30, weight: .regular))
        }.padding()
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
