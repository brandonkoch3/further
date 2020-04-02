//
//  QuestionsView.swift
//  SwiftUIDesignProject
//
//  Created by Brandon on 4/1/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import SwiftUI

struct QuestionsView: View {
    
    @State var questions: QuestionModel
    
    var body: some View {
        GeometryReader { geometry in
            
            ZStack {
                Color.offWhite
                VStack{
                    
                    
                    
                    Text(self.questions.sectionHeader)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.black)
                    Spacer()
                    VStack {
                        ForEach(self.questions.question) { question in
                            QuestionAnswerView(sectionImage: Image(systemName: self.questions.question.first == question ? "checkmark" : "xmark"), headerTitle: (self.questions.question.first == question) ? "Yes" : "No", subTitle: question.text, imageOffset: 5, questionID: question.id, questions: self.$questions)
                            Spacer()
                        }
                    }.frame(maxHeight: geometry.size.height / 3)
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            //
                        }) {
                            Image(systemName: "arrow.right")
                            .foregroundColor(.gray)
                            .font(.system(size: 50, weight: .ultraLight))
                        }.buttonStyle(LightButtonStyle())
                    }.padding()
                }.padding(.top, 70).padding(.leading, 10).padding(.trailing, 10)
            }.edgesIgnoringSafeArea(.all)
            
        }
        
    }
}

struct QuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionsView(questions: QuestionModel(id: UUID(), sectionHeader: "Are you experiencing symptoms you think could be related to COVID-19?", question: [Question(id: UUID(), text: "Fever, shortness of breath, etc.", response: false), Question(id: UUID(), text: "No I do not have symptoms", response: true)])).previewDevice("iPhone 11 Pro Max")
    }
}

struct QuestionAnswerView: View {
    var sectionImage: Image
    var headerTitle: String
    var subTitle: String
    var imageOffset: CGFloat? = 0
    var questionID: String
    @Binding var questions: QuestionModel
    private var thisQuestion: Question
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.offWhite)
                    .frame(width: geometry.size.width - 20, height: 100)
                    .shadow(color: Color("LightShadow"), radius: 8, x: -8, y: -8)
                    .shadow(color: Color("DarkShadow"), radius: 8, x: 8, y: 8)
                HStack {
                    ZStack {
                        Button(action: {

                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.offWhite)
                                    .frame(width: 60, height: 60)
                                    .shadow(color: Color("LightShadow"), radius: 8, x: -8, y: -8)
                                    .shadow(color: Color("DarkShadow"), radius: 8, x: 8, y: 8)
                                    .padding(.leading, 6)
                                
                                if self.thisQuestion.response {
                                    self.sectionImage
                                    .foregroundColor(self.colorScheme == .dark ? .red : .gray)
                                    .font(.system(size: 30))
                                    .multilineTextAlignment(.center)
                                    .offset(x: self.imageOffset!, y: 0)
                                }
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Text(self.headerTitle)
                            .font(.title)
                        Spacer()
                        Text(self.subTitle).font(.caption)
                        Spacer()
                    }.frame(height: 80).padding(.leading, 6.0)
                    Spacer()
                }
                .padding()
            }
        }
    }
    
    mutating func setupQuestion() {
        if let myQuestion = questions.question.first(where: { $0.id.uuidString == questionID }) {
            self.thisQuestion = myQuestion
        }
    }
}


