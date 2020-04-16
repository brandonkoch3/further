//
//  QuestionsView.swift
//  Further Extension
//
//  Created by Brandon on 4/15/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import SwiftUI
import Combine

struct QuestionsView: View {
    
    // MARK: Config
    var questionID: Int
    @EnvironmentObject var questions: QuestionsController
    @Binding var showingQuestion: Bool
    
    struct HeaderText: View {
        var title: String
        var body: some View {
            Text(title)
                .font(Font.custom("Rubik-Medium", size: 14.0))
            .foregroundColor(.white)
        }
    }
    
    // MARK: View
    var body: some View {
        VStack {
            List {
                HeaderText(title: self.questions.questions[self.questionID].sectionHeader).padding()
                ForEach(self.questions.questions[self.questionID].questions.indices) { idx in
                    
                    self.getButton(idx: idx)
                    
                }
            }
        }
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
    
    func getButton(idx: Int) -> some View {
        if self.shouldShowDoneButton() {
            
            return AnyView(
                NavigationLink(destination: EntryView()) {
                    QuestionAnswerView(question: self.$questions.questions[self.questionID].questions[idx])
                })

        } else {
                
            return AnyView(
                NavigationLink(destination: QuestionsView(questionID: self.nextQuestion(), showingQuestion: self.$showingQuestion).environmentObject(self.questions)) {
                    QuestionAnswerView(question: self.$questions.questions[self.questionID].questions[idx]).onTapGesture(perform: {print("HELP!")})
                })
            }
        }
    }

struct QuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionsView(questionID: 0, showingQuestion: .constant(true))
        .environmentObject(QuestionsController())
    }
}

struct QuestionAnswerView: View {
    @Binding var question: Question
    @EnvironmentObject var questionsController: QuestionsController
    var body: some View {
        self.infoView()
    }
    
    func infoView() -> some View {
        
        return Button(action: {
            // TODO: HAPTICS
            self.questionsController.updateAnswers(questionID: self.question.id, response: true)
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


