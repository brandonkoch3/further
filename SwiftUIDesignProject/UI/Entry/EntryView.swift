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
    @EnvironmentObject var environmentSettings: EnvironmentSettings
    @State private var pulsate = false
    @State var showingQuestionSheet = false
    @State var showingStorySheet = false
    private var haptics = Haptics()
    
    // Detector config
    @EnvironmentObject var detector: PersonDetectee
    @ObservedObject var storyController = StoriesController()
    
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
                                .onAppear(perform: haptics.intenseDetection)
                                .buttonStyle(DarkButtonStyle())
                                .contextMenu {
                                    Button(action: {
                                        self.haptics.allowed.toggle()
                                    }) {
                                        Image(systemName: haptics.allowed ? "bell" : "bell.slash")
                                        Text(haptics.allowed ? "Disable Vibrations" : "Enable Vibrations")
                                    }
                                }
                        } else {
                            PersonButton(pulsate: $pulsate)
                                .onAppear(perform: haptics.intenseDetection)
                                .buttonStyle(LightButtonStyle())
                                .contextMenu {
                                    Button(action: {
                                        self.haptics.allowed.toggle()
                                    }) {
                                        Image(systemName: haptics.allowed ? "bell" : "bell.slash")
                                        Text(haptics.allowed ? "Disable Vibrations" : "Enable Vibrations")
                                    }
                                }
                        }
                        Text("Someone Is Nearby!")
                            .foregroundColor(colorScheme == .dark ? .offWhite : .lairDarkGray)
                            .bold()
                    } else {
                        if colorScheme == .dark {
                            SearchButton(pulsate: $pulsate)
                                .onAppear(perform: haptics.cancelHaptics)
                                .buttonStyle(DarkButtonStyle())
                        } else {
                            SearchButton(pulsate: $pulsate)
                                .onAppear(perform: haptics.cancelHaptics)
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
                        if environmentSettings.env.allowQuestions {
                            QuestionButton(showingQuestionSheet: $showingQuestionSheet, userID: self.detector.myID)
                        }
                        Spacer()
                        if environmentSettings.env.allowStories {
                            StoryButton(showingStorySheet: $showingStorySheet)
                        }
                    } else {
                        if environmentSettings.env.allowQuestions {
                            QuestionButton(showingQuestionSheet: $showingQuestionSheet, userID: self.detector.myID)
                        }
                        Spacer()
                        if environmentSettings.env.allowStories {
                            StoryButton(showingStorySheet: $showingStorySheet)
                        }
                    }
                }
            }.padding()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct EntryView_Previews: PreviewProvider {
    static var previews: some View {
        EntryView()
            .environmentObject(PersonDetectee())
            .environmentObject(EnvironmentSettings())
            .environment(\.colorScheme, .light)
    }
}

struct QuestionButton: View {
    @Binding var showingQuestionSheet: Bool
    @Environment(\.colorScheme) var colorScheme
    var questions = QuestionsController()
    var userID: String
    var body: some View {
        Button(action: {
            self.showingQuestionSheet.toggle()
        }) {
            Image(systemName: "list.dash")
                .foregroundColor(self.colorScheme == .dark ? Color.gray : Color.lairDarkGray)
                .font(.system(size: 25, weight: .regular))
        }.sheet(isPresented: $showingQuestionSheet) {
            QuestionView(showingQuestionSheet: self.$showingQuestionSheet).environmentObject(self.questions)
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

struct StoryButton: View {
    @Binding var showingStorySheet: Bool
    @Environment(\.colorScheme) var colorScheme
    var storiesController = StoriesController()
    var body: some View {
        Button(action: {
            self.showingStorySheet.toggle()
        }) {
            Image(systemName: "person.3")
                .foregroundColor(self.colorScheme == .dark ? Color.gray : Color.lairDarkGray)
                .font(.system(size: 25, weight: .regular))
        }.sheet(isPresented: $showingStorySheet) {
            StoryView(storyController: self.storiesController)
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
