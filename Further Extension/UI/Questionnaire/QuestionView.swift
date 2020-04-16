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
    
    // Questions
    @State private var currentQuestion = -1
    
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
    
    struct QuestionHeaderText: View {
        var title: String
        var body: some View {
            Text(title)
                .font(Font.custom("Rubik-Medium", size: 14.0))
            .foregroundColor(.white)
        }
    }
    
    // Main View
    var body: some View {
        VStack {
            
            if currentQuestion == -1 {
                
                Group {
                    
                    // Header
                    HeaderText()
                    
                    // Body
                    self.informationView()
                }
                
            } else if 0...2 ~= self.currentQuestion {
                
                Group {
                    List {
                        
                        // Header
                        QuestionHeaderText(title: self.questions.questions[self.currentQuestion].sectionHeader)
                        .padding()
                        .transition(.scale)
                        
                        // Body
                        QuestionAnswer(question: self.$questions.questions[self.currentQuestion].questions[0], questionID: self.$currentQuestion)
                        
                        QuestionAnswer(question: self.$questions.questions[0].questions[1], questionID: self.$currentQuestion)
                    }
                }
            } else {
                Group {
                    Text("Your responses have been saved.")
                    
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                    }
                }
            }
        }
    }
    
    // Information View
    func informationView() -> some View {
        return List {
            InformationView(sectionImage: Image("dark_hand_icon"), headerTitle: "Privacy", subTitle: "Answers are anonymous.")
            InformationView(sectionImage: Image("dark_people_icon"), headerTitle: "Honesty", subTitle: "Be truthful, please.")
            InformationView(sectionImage: Image("dark_health_icon"), headerTitle: "Health", subTitle: "Answers will help others.")
            
            Button(action: {
                self.currentQuestion += 1
            }) {
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

struct QuestionAnswer: View {
    @Binding var question: Question
    @EnvironmentObject var questionsController: QuestionsController
    @Binding var questionID: Int
    var body: some View {
        self.infoView()
    }
    
    func infoView() -> some View {
        
        return Button(action: {
            // TODO: HAPTICS
            self.questionsController.updateAnswers(questionID: self.question.id, response: true)
            self.questionID += 1
        }) {
            HStack {
                Spacer()
                Text(question.headline)
                    .font(Font.custom("Rubik-Medium", size: 14.0))
                Spacer()
            }
        }
    }
}
