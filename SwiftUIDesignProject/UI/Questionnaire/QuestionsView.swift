//
//  QuestionsView.swift
//  SwiftUIDesignProject
//
//  Created by Brandon on 4/1/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import SwiftUI
import Combine

struct QuestionsView: View {
    
    // MARK: Config
    var questionID: Int
    @EnvironmentObject var questions: QuestionsController
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @Binding var showingQuestion: Bool
    
    // MARK: UI Helpers
    
    
    // MARK: View
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if self.colorScheme == .dark {
                    LinearGradient(Color.darkStart, Color.darkEnd)
                } else {
                    Color.offWhite
                }
                VStack{
                    Text(self.questions.questions[self.questionID].sectionHeader)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(self.colorScheme == .dark ? .white : .black)
                        .padding(.top, geometry.size.height < 600.0 ? -30 : 0).padding(.bottom, geometry.size.height < 600.0 ? 30.0 : 0)
                    Spacer()
                    VStack {
                        ForEach(self.questions.questions[self.questionID].questions.indices) { idx in
                            QuestionAnswerView(question: self.$questions.questions[self.questionID].questions[idx], imageOffset: 5).frame(height: 120)
                            Spacer()
                        }
                        Spacer()
                    }.frame(maxHeight: geometry.size.height / 3)
                    Spacer()
                    HStack {
                        Spacer()
                        if self.colorScheme == .light {
                            if self.shouldShowDoneButton() {
                                self.getDoneButtonLight()
                            } else {
                                self.advanceButtonLight()
                            }
                        } else {
                            if self.shouldShowDoneButton() {
                                self.getDoneButtonDark()
                            } else {
                                self.advanceButtonDark()
                            }
                        }
                    }.padding()
                }.padding(.top, 70).padding(.leading, 10).padding(.trailing, 10)
            }.edgesIgnoringSafeArea(.all)
        }
    }
    
    func shouldShowBackArrow() -> Bool {
        return !(self.questionID == 0)
    }
    
    func shouldShowDoneButton() -> Bool {
        if !self.questions.answers!.hasBeenTested && self.questionID == 1 {
            return true
        }
        return self.questionID == self.questions.questions.count - 1
    }
    
    func nextQuestion() -> Int {
        switch self.questionID {
        case 0:
            return 1
        case 1:
            return 2
        case 2:
            return 0
        default:
            return 0
        }
    }
    
    func getDoneButtonLight() -> some View {
        return Button(action: {
            self.showingQuestion.toggle()
        }) {
            Image(systemName: "checkmark")
            .foregroundColor(.gray)
            .font(.system(size: 30, weight: .ultraLight))
        }.buttonStyle(LightButtonStyle(lightMode: true)).padding(.bottom, 5).padding(.trailing, -5)
    }
    
    func getDoneButtonDark() -> some View {
        return Button(action: {
            self.showingQuestion.toggle()
        }) {
            Image(systemName: "checkmark")
            .foregroundColor(.gray)
            .font(.system(size: 30, weight: .ultraLight))
        }.buttonStyle(DarkButtonStyle()).padding(.bottom, 5).padding(.trailing, -5)
    }
    
    func advanceButtonLight() -> some View {
        return NavigationLink(destination: QuestionsView(questionID: self.nextQuestion(), showingQuestion: self.$showingQuestion).environmentObject(self.questions)) {
            Image(systemName: "arrow.right")
            .foregroundColor(.gray)
            .font(.system(size: 30, weight: .ultraLight))
        }.padding(.bottom, 5).padding(.trailing, -5.0).buttonStyle(LightButtonStyle(lightMode: true))
    }
    
    func advanceButtonDark() -> some View {
        return NavigationLink(destination: QuestionsView(questionID: self.nextQuestion(), showingQuestion: self.$showingQuestion).environmentObject(self.questions)) {
            Image(systemName: "arrow.right")
            .foregroundColor(.gray)
            .font(.system(size: 30, weight: .ultraLight))
        }.padding(.bottom, 5).padding(.trailing, -5.0).buttonStyle(DarkButtonStyle())
    }
}

struct QuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            QuestionsView(questionID: 0, showingQuestion: .constant(true))
            .previewDevice("iPhone SE")
            .environmentObject(QuestionsController())
            .environment(\.colorScheme, .dark)
            
            QuestionsView(questionID: 0, showingQuestion: .constant(true))
            .previewDevice("iPhone 11 Pro Max")
            .environmentObject(QuestionsController())
            .environment(\.colorScheme, .dark)
        }
        
    }
}

struct QuestionAnswerView: View {
    @Binding var question: Question
    @EnvironmentObject var questionsController: QuestionsController
    var imageOffset: CGFloat? = 0
    @Environment(\.colorScheme) var colorScheme
    let generator = UIImpactFeedbackGenerator(style: .light)
    var body: some View {
        GeometryReader { geometry in
            if self.colorScheme == .light {
                self.lightView(geometry: geometry)
            } else {
                self.darkView(geometry: geometry)
            }
        }
    }
    
    func lightView(geometry: GeometryProxy) -> some View {
        return ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.offWhite)
                .frame(width: geometry.size.width - 20, height: 100)
                .shadow(color: Color("LightShadow"), radius: 8, x: -8, y: -8)
                .shadow(color: Color("DarkShadow"), radius: 8, x: 8, y: 8)
            HStack {
                ZStack {
                    Button(action: {
                        self.generator.impactOccurred()
                        self.questionsController.updateAnswers(questionID: self.question.id, response: true)
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.offWhite)
                                .frame(width: 60, height: 60)
                                .shadow(color: Color("LightShadow"), radius: 8, x: -8, y: -8)
                                .shadow(color: Color("DarkShadow"), radius: 8, x: 8, y: 8)
                                .padding(.leading, 6)
                            
                            if self.$question.response.wrappedValue {
                                Image(systemName: self.question.icon)
                                .foregroundColor(.gray)
                                .font(.system(size: 30))
                                .multilineTextAlignment(.center)
                                .offset(x: self.imageOffset!, y: 0)
                            }
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text(self.question.headline)
                        .font(.title).padding(.top, 20)
                    Text(self.question.subtitle).font(.caption).frame(height: 60.0)
                    Spacer()
                }.frame(height: 80).padding(.leading, 6.0)
                Spacer()
            }
            .padding()
        }
    }
    
    func darkView(geometry: GeometryProxy) -> some View {
        return ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(LinearGradient(Color.darkStart, Color.darkEnd))
                .frame(width: geometry.size.width - 20, height: 100)
                .shadow(color: Color("LightShadow"), radius: 8, x: -8, y: -8)
                .shadow(color: Color("DarkShadow"), radius: 8, x: 8, y: 8)
            HStack {
                ZStack {
                    Button(action: {
                        self.generator.impactOccurred()
                        self.questionsController.updateAnswers(questionID: self.question.id, response: true)
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(LinearGradient(Color.darkStart, Color.darkEnd))
                                .frame(width: 60, height: 60)
                                .shadow(color: Color("LightShadow"), radius: 8, x: -8, y: -8)
                                .shadow(color: Color("DarkShadow"), radius: 8, x: 8, y: 8)
                                .padding(.leading, 6)
                            
                            if self.$question.response.wrappedValue {
                                Image(systemName: self.question.icon)
                                    .foregroundColor(.red)
                                    .font(.system(size: 30))
                                    .multilineTextAlignment(.center)
                                    .offset(x: self.imageOffset!, y: 0)
                            }
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text(self.question.headline)
                        .font(.title).padding(.top, 20)
                    Text(self.question.subtitle).font(.caption).frame(height: 60.0)
                    Spacer()
                }.frame(height: 80).padding(.leading, 6.0)
                Spacer()
            }
            .padding()
        }
    }
}


