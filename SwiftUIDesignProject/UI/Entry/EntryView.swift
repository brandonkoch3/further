//
//  EntryView.swift
//  SwiftUIDesignProject
//
//  Created by Brandon on 3/17/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import SwiftUI

struct EntryView: View {
    
    // UI Config
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var environmentSettings: EnvironmentSettings
    @State private var pulsate = false
    @State var showingQuestionSheet = false
    @State var showingStorySheet = false
    
    // Detector config
    @ObservedObject var detector = PersonDetectee()
    @ObservedObject var questionsController = QuestionsController()
    @ObservedObject var storyController = StoriesController()
    
    var body: some View {
        ZStack {
            EntryBackgroundView()
            VStack {
                Spacer()
                VStack {
                    VStack {
                        HeartView(detector: detector)
                        Spacer()
                        MainTextView(detector: detector)
                    }.frame(maxHeight: 240)
                }
                Spacer()
                HStack {
                    if environmentSettings.env.allowQuestions {
                        QuestionButton(showingQuestionSheet: $showingQuestionSheet).environmentObject(self.questionsController)
                    }
                    Spacer()
                    if environmentSettings.env.allowStories {
                        StoryButton(showingStorySheet: $showingStorySheet, storiesController: self.storyController)
                    }
                }
            }.padding()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct EntryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EntryView()
                .environmentObject(EnvironmentSettings())
                .environment(\.colorScheme, .dark)
                .previewDevice("iPhone 11 Pro Max")
            
            EntryView()
            .environmentObject(EnvironmentSettings())
            .environment(\.colorScheme, .light)
            .previewDevice("iPhone SE")
        }
        
    }
}

struct HeartView: View {
    
    // UI Config
    @Environment(\.colorScheme) var colorScheme
    @State private var pulsate = false
    @State private var showingActionSheet = false
    
    // Person Config
    @ObservedObject var detector: PersonDetectee
    
    // View
    var body: some View {
        ZStack {
            Image(colorScheme == .light ? "light_heart_back" : "dark_heart_back")
            Image(colorScheme == .light ? "light_heart_middle" : "dark_heart_middle")
            Image(colorScheme == .light ? "light_heart_\(self.detector.personFound ? "on" : "off")" : "dark_heart_\(self.detector.personFound ? "on" : "off")")
            .scaleEffect(pulsate ? 0.5 : 1)
                .animation(Animation.easeInOut(duration: 1).delay(0).repeat(while: pulsate))
                .onAppear() {
                    self.pulsate.toggle()
                }
        }.actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text("Settings"), message: nil, buttons: [.default(Text("Test"))]) 
        }
    }
}

struct MainTextView: View {
    
    // UI Config
    @Environment(\.colorScheme) var colorScheme
    
    // Person Config
    @ObservedObject var detector: PersonDetectee
    
    // View
    var body: some View {
        Text(detector.personFound ? "Someone is nearby!" : "Checking for others")
            .font(Font.custom("Rubik-Regular", size: 26.67))
            .foregroundColor(colorScheme == .light ? Color(UIColor(red: 50.0/255.0, green: 54.0/255.0, blue: 83.0/255.0, alpha: 1.0)) : Color(UIColor(red: 172.0/255.0, green: 178.0/255.0, blue: 181.0/255.0, alpha: 1.0)))
    }
}








