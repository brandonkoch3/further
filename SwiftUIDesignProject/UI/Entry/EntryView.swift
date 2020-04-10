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
                        QuestionButton(showingQuestionSheet: $showingQuestionSheet)
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
                .environment(\.colorScheme, .light)
                .previewDevice("iPhone 11 Pro Max")
            
            EntryView()
            .environmentObject(EnvironmentSettings())
            .environment(\.colorScheme, .light)
            .previewDevice("iPhone SE")
        }
        
    }
}










