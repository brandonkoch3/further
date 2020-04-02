//
//  QuestionsController.swift
//  SwiftUIDesignProject
//
//  Created by Brandon on 4/1/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation

class QuestionsController: ObservableObject {
    
    @Published var questions = [QuestionModel]()
    
    init() {
        setupQuestions()
    }
    
    /// We are manually setting the questions given the simplicity of this app.  In other cases, we may want to download the questions from a server.
    private func setupQuestions() {
        let questionA = QuestionModel(sectionHeader: "Are you experiencing symptoms you think may be related to COVID-19?", question: [Question(text: "Fever, shortness of breath, and difficulty breathing are common symptoms.", response: false), Question(text: "I am not experiencing symptoms that seem related to COVID-19.", response: true)])
        
        let questionB = QuestionModel(sectionHeader: "Have you been professionally tested for COVID-19?", question: [Question(text: "Yes, I have visitied a testing facility and have been tested using a CDC-approved test.", response: false), Question(text: "No, I have not been professionally tested for COVID-19.", response: true)])
        
        let questionC = QuestionModel(sectionHeader: "Did you show a positive, confirmed test for COVID-19?", question: [Question(text: "Yes, my test was confirmed to show a positive result for COVID-19.", response: false), Question(text: "No, my test did not show a positive result/I tested negative for COVID-19.", response: true)])
        
        questions.append(contentsOf: [questionA, questionB, questionC])
    }
    
}
