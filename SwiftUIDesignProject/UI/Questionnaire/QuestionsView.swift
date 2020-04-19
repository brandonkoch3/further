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
    @State var matching: [String] = ["unwell", "different", "professional", "positively"]
    
    struct HeaderText: View {
        var body: some View {
            VStack {
                HStack {
                    Text("Wellness")
                    .font(Font.custom("Rubik-Medium", size: 34.0))
                    .foregroundColor(.white)
                    Spacer()
                }.padding(.leading, 16.0)
                
                HStack {
                    Text("Questionnaire")
                        .font(Font.custom("Rubik-Medium", size: 16.5))
                    .foregroundColor(.white)
                    Spacer()
                }.padding(.leading, 16.0).padding(.top, 5.0)
            }
        }
    }
    
    struct HighlightedText: View {
        var text: String
        let matching: [String]
        var geometry: GeometryProxy

        init(_ text: String, matching: [String], geometry: GeometryProxy) {
            self.matching = matching
            var myText = text
            _ = self.matching.compactMap { myText = myText.replacingOccurrences(of: $0, with: "<SPLIT>>\($0)<SPLIT>")}
            self.text = myText
            self.geometry = geometry
        }

        var body: some View {
            let tagged = text
            let split = tagged.components(separatedBy: "<SPLIT>")
            return split.reduce(Text("")) { (a, b) -> Text in
                guard !b.hasPrefix(">") else {
                    return a + Text(b.dropFirst()).font(Font.custom("Rubik-Medium", size: geometry.size.height < 600.0 ? 24.0 : 34.0))
                }
                return a + Text(b)
            }
        }
    }
    
    
    // MARK: UI Helpers
    
    
    // MARK: View
    var body: some View {
        
        GeometryReader { geometry in
            ZStack {
                Image(self.colorScheme == .light ? "day_answers_gradient" : "night_answers_gradient").resizable()
                VStack {
                    Spacer()
                    HStack {
                        HighlightedText(self.questions.questions[self.questionID].sectionHeader, matching: self.matching, geometry: geometry)
                            .font(Font.custom("Rubik-Light", size: geometry.size.height < 600.0 ? 24.0 : 34.0))
                        .foregroundColor(.white)
                            .padding([.leading, .trailing], 15.0)
                        .padding(.top, geometry.size.height < 600.0 ? 15.0 : 60.0)
                    }
                    
                    // Rectangle
                    ZStack {
                        Rectangle().fill(self.colorScheme == .light ? LinearGradient(Color.offWhite, Color.offWhite) : LinearGradient(Color(hex: "25282d"), Color(hex: "25282d")))
                        .cornerRadius(20, corners: [.topLeft, .topRight])
                        
                        // Information
                        VStack {
                            VStack {
                                ForEach(self.questions.questions[self.questionID].questions.indices) { idx in
                                    QuestionAnswerView(geometry: geometry, question: self.$questions.questions[self.questionID].questions[idx])
                                    .padding(.top, geometry.size.height < 600.0 ? 25.0 : 50.0)
                                    .padding([.leading, .trailing], 15.0)
                                }
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: geometry.size.width, height: geometry.size.height < 600.0 ? 60.0 : 100.0)
                                    .padding(.top, geometry.size.height < 600.0 ? 25.0 : 50.0)
                                    .padding([.leading, .trailing], 15.0)
                            }.frame(width: geometry.size.width, height: geometry.size.height / (geometry.size.height < 600.0 ? 1.5 : 1.6))

                            Spacer()
                        }
                        
                        // Button
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                self.getButton().buttonStyle(LightButtonStyle(lightMode: self.colorScheme == .light ? true : false))
                                .scaleEffect(geometry.size.height < 600.0 ? 0.8 : 1.0)
                                .padding(.trailing, geometry.size.height < 600.0 ? 6.0 : 12.9)
                                .padding(.bottom, geometry.size.height < 600.0 ? 35.0 : 50.0)
                            }
                        }
                    }
                }
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
    
    func getButton() -> some View {
        if self.shouldShowDoneButton() {
            return AnyView(Button(action: {
                self.showingQuestion.toggle()
            }) {
                Image(systemName: "checkmark")
                .foregroundColor(.gray)
                .font(.system(size: 30, weight: .ultraLight))
            }.buttonStyle(LightButtonStyle(lightMode: colorScheme == .light ? true : false)))
        } else {
            return AnyView(NavigationLink(destination: QuestionsView(questionID: self.nextQuestion(), showingQuestion: self.$showingQuestion).environmentObject(self.questions)) {
                Image(systemName: "arrow.right")
                .foregroundColor(.gray)
                .font(.system(size: 30, weight: .ultraLight))
            }.buttonStyle(LightButtonStyle(lightMode: colorScheme == .light ? true : false)))
        }
    }
    
    func getDoneButton() -> some View {
        return Button(action: {
            self.showingQuestion.toggle()
        }) {
            Image(systemName: "checkmark")
            .foregroundColor(.gray)
            .font(.system(size: 30, weight: .ultraLight))
        }.buttonStyle(LightButtonStyle(lightMode: colorScheme == .light ? true : false))
    }
    
    func advanceButton() -> some View {
        return NavigationLink(destination: QuestionsView(questionID: self.nextQuestion(), showingQuestion: self.$showingQuestion).environmentObject(self.questions)) {
            Image(systemName: "arrow.right")
            .foregroundColor(.gray)
            .font(.system(size: 30, weight: .ultraLight))
        }.buttonStyle(LightButtonStyle(lightMode: colorScheme == .light ? true : false))
    }
}

struct QuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            QuestionsView(questionID: 2, showingQuestion: .constant(true))
            .previewDevice("iPhone SE")
            .environmentObject(QuestionsController())
            .environment(\.colorScheme, .light)
            
            QuestionsView(questionID: 2, showingQuestion: .constant(true))
            .previewDevice("iPhone 11 Pro Max")
            .environmentObject(QuestionsController())
            .environment(\.colorScheme, .light)
        }
        
    }
}

struct QuestionAnswerView: View {
    var geometry: GeometryProxy
    @Binding var question: Question
    @EnvironmentObject var questionsController: QuestionsController
    @Environment(\.colorScheme) var colorScheme
    let generator = UIImpactFeedbackGenerator(style: .light)
    var body: some View {
        self.infoView()
    }
    
    func infoView() -> some View {
        
        return ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(colorScheme == .light ? LinearGradient(Color.offWhite, Color.offWhite) : LinearGradient(Color(hex: "25282d"), Color(hex: "25282d")))
                .frame(height: 100)
                .shadow(color: colorScheme == .light ? Color("LightShadow") : Color(hex: "505050"), radius: colorScheme == .light ? 8 : 0.5, x: colorScheme == .light ? -8 : -1, y: colorScheme == .light ? -8 : -1)
                .shadow(color: colorScheme == .light ? Color("DarkShadow") : .black, radius: 8, x: colorScheme == .light ? 8 : -1, y: colorScheme == .light ? 8 : 1)
            HStack {
                Button(action: {
                    self.generator.impactOccurred()
                    self.questionsController.updateAnswers(questionID: self.question.id, response: true)
                }) {
                    Image(self.question.response ? "\(colorScheme == .light ? "light" : "dark")_selected" : "\(colorScheme == .light ? "light" : "dark")_deselected")
                }.buttonStyle(PlainButtonStyle())
                VStack(alignment: .leading, spacing: 5.0) {
                    Text(self.question.headline)
                        .font(Font.custom("Rubik-Medium", size: 23.3))
                    Text(self.question.subtitle)
                        .font(Font.custom("Rubik-Light", size: geometry.size.height < 600.0 ? 12.0 : 15.5))
                }
                Spacer()
            }
        }
    }
}


