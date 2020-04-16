//
//  QuestionView.swift
//  Further Extension
//
//  Created by Brandon on 4/14/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import SwiftUI

struct QuestionView: View {
    
    // UI
    @Binding var showingQuestionSheet: Bool
    @State private var showingQuestion = false
    @Environment(\.presentationMode) var presentationMode
    
    // Helpers
    @EnvironmentObject var questions: QuestionsController
    
    @Environment(\.colorScheme) var colorScheme
    
    // Header Text
    struct HeaderText: View {
        var body: some View {
            VStack {
                HStack {
                    Text("COVID-19")
                        .font(Font.custom("Rubik-Medium", size: 17.0))
                    .foregroundColor(.white)
                    Spacer()
                }.padding(.leading, 16.0)
                
                HStack {
                    Text("Questionnaire")
                        .font(Font.custom("Rubik-Medium", size: 12.0))
                    .foregroundColor(.white)
                    Spacer()
                }.padding(.leading, 16.0).padding(.top, 3.0)
            }
        }
    }
    
    // Main View
    var body: some View {
        VStack {
            
            // Header
            HeaderText()

            // Information
            self.informationView()
            
        }
    }
    
    // Information View
    func informationView() -> some View {
        return List {
            InformationView(sectionImage: Image("dark_hand_icon"), headerTitle: "Privacy", subTitle: "Answers are anonymous.")
            InformationView(sectionImage: Image("dark_people_icon"), headerTitle: "Honesty", subTitle: "Be truthful, please.")
            InformationView(sectionImage: Image("dark_health_icon"), headerTitle: "Health", subTitle: "Answers will help others.")
            
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Test")
            }
            
            NavigationLink(destination: QuestionsView(questionID: 0, showingQuestion: self.$showingQuestion)) {
                HStack {
                    Spacer()
                    Text("Get Started")
                        .font(Font.custom("Rubik-Medium", size: 14))
                    Spacer()
                }
            }
        }
    }
}

struct QuestionView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionView(showingQuestionSheet: .constant(false))
    }
}

// InformationView
struct InformationView: View {
    var sectionImage: Image
    var headerTitle: String
    var subTitle: String
    var imageOffset: CGFloat? = 0
    var body: some View {
        self.infoView()
    }
    
    func infoView() -> some View {
        return HStack {
            self.sectionImage.resizable().scaledToFit().frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Text(self.headerTitle)
                    .font(Font.custom("Rubik-Medium", size: 14))
                Text(self.subTitle)
                    .font(Font.custom("Rubik-Light", size: 11))
            }
        }
    }
}
