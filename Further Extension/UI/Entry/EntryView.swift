//
//  EntryView.swift
//  Further Extension
//
//  Created by Brandon Koch on 4/6/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import SwiftUI

struct EntryView: View {
    
    // UI Config
    @EnvironmentObject var detector: PersonDetectee
    
    @State private var showingQuestionSheet = false
    @State private var showingStorySheet = false
    
    // Environment/Features
    @EnvironmentObject var environmentSettings: EnvironmentSettings
    @ObservedObject var questionsController = QuestionsController()
    @ObservedObject var storyController = StoriesController()
    
    var body: some View {
        VStack {
            
            HeartView(detector: detector)
            
            Spacer()
            
            MainTextView(detector: detector).padding(.top, -12.0)

        }
        
        
        .contextMenu(menuItems: {
            NavigationLink(destination: QuestionView(showingQuestionSheet: $showingQuestionSheet).environmentObject(self.questionsController)) {
                VStack{
                    Image(systemName: "list.dash")
                        .font(.system(size: 32.0))
                    Text("Questionnaire")
                }
            }
            
            NavigationLink(destination: QuestionView(showingQuestionSheet: $showingQuestionSheet)) {
                VStack{
                    Image(systemName: "person.3")
                        .font(.system(size: 24.0))
                    Text("Interactions")
                }
            }
        })
    }
}

struct EntryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            EntryView()
                .environmentObject(PersonDetectee())
                .environmentObject(EnvironmentSettings())
                .previewDevice("Apple Watch Series 4 - 44mm")
            
            EntryView()
                .environmentObject(PersonDetectee())
                .environmentObject(EnvironmentSettings())
                .previewDevice("Apple Watch Series 2 - 38mm")
            
        }
    }
}

struct QuestionButton: View {
    
    // UI Config
    @Binding var showingQuestionSheet: Bool
    
    // Helpers
    @EnvironmentObject var questions: QuestionsController
    
    var body: some View {
        Image(systemName: "list.dash")
        .foregroundColor(Color.gray)
        .font(.system(size: 18, weight: .regular))
        .padding()
        .onTapGesture(perform: {
            self.showingQuestionSheet.toggle()
        }).sheet(isPresented: $showingQuestionSheet) {
            EmptyView()
        }
    }
}

struct StoryButton: View {
    
    // UI Config
    @Binding var showingStorySheet: Bool
    
    // Helpers
    var storiesController = StoriesController()
    
    // View
    var body: some View {
        Image(systemName: "person.3")
        .foregroundColor(Color.gray)
        .font(.system(size: 12, weight: .regular))
        .padding()
        .onTapGesture(perform: {
            self.showingStorySheet.toggle()
        }).sheet(isPresented: $showingStorySheet) {
            EmptyView()
        }
    }
}

struct MainTextView: View {
    
    // Person Config
    @ObservedObject var detector: PersonDetectee
    
    // View
    var body: some View {
        Text(detector.personFound ? "Someone is nearby!" : "Checking for others")
            .font(Font.custom("Rubik-Regular", size: 13.34))
            .foregroundColor(Color(UIColor(red: 172.0/255.0, green: 178.0/255.0, blue: 181.0/255.0, alpha: 1.0)))
    }
}

struct HeartView: View {
    
    @State private var pulsate = false
    @ObservedObject var detector: PersonDetectee
    
    var body: some View {
        ZStack(alignment: .center) {
            
            Image("light_heart_back")
                .resizable()
                .scaledToFit()
                .padding()
            
            Image("light_heart_middle")
                .resizable()
                .scaledToFit()
                .padding()
                .scaleEffect(0.7)
            
            Image("light_heart_\(self.detector.personFound ? "on" : "off")")
                .resizable()
                .scaledToFit()
                .padding()
                .scaleEffect(pulsate ? 0.175 : 0.35)
                .animation(Animation.easeInOut(duration: 1).delay(0).repeat(while: pulsate))
                .onAppear() {
                    self.pulsate.toggle()
                    self.detector.personFound ? WKInterfaceDevice.current().play(.success) : nil
            }
        }
    }
}
