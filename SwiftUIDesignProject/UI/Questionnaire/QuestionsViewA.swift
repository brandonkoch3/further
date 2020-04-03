////
////  QuestionsView.swift
////  SwiftUIDesignProject
////
////  Created by Brandon on 4/1/20.
////  Copyright © 2020 Brandon. All rights reserved.
////
//
//import SwiftUI
//import Combine
//
//struct QuestionsViewA: View {
//    
//    // MARK: Config
//    var questionID: Int
//    @EnvironmentObject var questions: QuestionsController
//    @Environment(\.presentationMode) var presentationMode
//    @Environment(\.colorScheme) var colorScheme
//    @State var showingQuestion = false
//    
//    // MARK: View
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                if self.colorScheme == .dark {
//                    LinearGradient(Color.darkStart, Color.darkEnd)
//                } else {
//                    Color.offWhite
//                }
//                VStack{
//                    Text(self.questions.questions[self.questionID].sectionHeader)
//                        .font(.largeTitle)
//                        .fontWeight(.semibold)
//                        .foregroundColor(self.colorScheme == .dark ? .white : .black)
//                    Spacer()
//                    VStack {
//                        ForEach(self.questions.questions[self.questionID].questions.indices) { idx in
//                            QuestionAnswerView(question: self.$questions.questions[self.questionID].questions[idx], imageOffset: 5)
//                            Spacer()
//                        }
//                        Spacer()
//                    }.frame(maxHeight: geometry.size.height / 3)
//                    Spacer()
//                    HStack {
//                        Spacer()
//                        if self.colorScheme == .light {
//                            self.advanceButtonLight()
//                        } else {
//                            self.advanceButtonDark()
//                        }
//                    }.padding()
//                }.padding(.top, 70).padding(.leading, 10).padding(.trailing, 10)
//            }.edgesIgnoringSafeArea(.all)
//        }
//    }
//    
//    func shouldShowBackArrow() -> Bool {
//        return !(self.questionID == 0)
//    }
//    
//    func shouldShowDoneButton() -> Bool {
//        if !self.questions.answers!.hasBeenTested && self.questionID == 1 {
//            return true
//        }
//        return self.questionID == self.questions.questions.count - 1
//    }
//    
//    func nextQuestion() -> Int {
//        switch self.questionID {
//        case 0:
//            return 1
//        case 1:
//            return 2
//        case 2:
//            return 0
//        default:
//            return 0
//        }
//    }
//    
//    func advanceButtonLight() -> some View {
//        return Button(action: {
//            if self.shouldShowDoneButton() {
//                self.presentationMode.wrappedValue.dismiss()
//            } else {
//                self.showingQuestion.toggle()
//            }
//        }) {
//            Image(systemName: self.shouldShowDoneButton() ? "checkmark" : "arrow.right")
//            .foregroundColor(.gray)
//            .font(.system(size: 30, weight: .ultraLight))
//        }
//        .sheet(isPresented: self.$showingQuestion) {
//            QuestionsView(questionID: self.nextQuestion()).environmentObject(QuestionsController())
//        }
//        .buttonStyle(LightButtonStyle())
//    }
//    
//    func advanceButtonDark() -> some View {
//        return Button(action: {
//            if self.shouldShowDoneButton() {
//                self.presentationMode.wrappedValue.dismiss()
//            } else {
//                self.showingQuestion.toggle()
//            }
//        }) {
//            Image(systemName: self.shouldShowDoneButton() ? "checkmark" : "arrow.right")
//            .foregroundColor(.gray)
//            .font(.system(size: 30, weight: .ultraLight))
//        }
//        .sheet(isPresented: self.$showingQuestion) {
//            QuestionsView(questionID: self.nextQuestion()).environmentObject(QuestionsController())
//        }
//        .buttonStyle(DarkButtonStyle())
//    }
//}
//
//struct QuestionsViewA_Previews: PreviewProvider {
//    static var previews: some View {
//        QuestionsView(questionID: 1)
//            .previewDevice("iPhone 11 Pro Max")
//            .environmentObject(QuestionsController())
//            .environment(\.colorScheme, .dark)
//    }
//}
//
