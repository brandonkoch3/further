//
//  QuestionsController.swift
//  SwiftUIDesignProject
//
//  Created by Brandon on 4/1/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class QuestionsController: ObservableObject {
    
    @Published var questions = [QuestionModel]()
    @Published var answers: CovidModel?
    private var myID: String!
    
    // Combine
    var answerSubscriber: AnyCancellable?
    var publishSubscriber: AnyCancellable?
    var updateCancellable: AnyCancellable?
    
    // Helpers
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let defaults = UserDefaults.standard
    
    init() {
        if let myID = UserDefaults.standard.string(forKey: "deviceID") {
            self.myID = myID
        } else {
            let newID = UUID().uuidString
            self.myID = newID
            UserDefaults.standard.set(newID, forKey: "deviceID")
        }
        
        if let savedData = defaults.object(forKey: "answers") as? Data {
            if let loadedData = try? decoder.decode(CovidModel.self, from: savedData) {
                self.answers = loadedData
            }
        }
        
        if self.answers == nil {
            self.answers = CovidModel(id: self.myID, feelingSick: false, hasBeenTested: false, testResult: false, update: Date().timeIntervalSince1970, didAnswer: false)
        }
        
        answerSubscriber = $answers
            .receive(on: RunLoop.main)
            .sink(receiveValue: { model in
                self.saveAnswers()
            })
        
        publishSubscriber = $answers
            .receive(on: RunLoop.main)
            .filter({ $0!.testResult == true })
            .sink(receiveValue: { positive in
                self.publishAnswer() { update in
                    
                }
            })
        
        setupQuestions()
        
    }
    
    public func updateAnswers(questionID: Int, response: Bool) {
        switch questionID {
        case 0:
            self.answers!.feelingSick = true
            self.questions[0].questions[0].response = true
            self.questions[0].questions[1].response = false
        case 1:
            self.answers!.feelingSick = false
            self.questions[0].questions[0].response = false
            self.questions[0].questions[1].response = true
        case 2:
            self.answers!.hasBeenTested = true
            self.questions[1].questions[0].response = true
            self.questions[1].questions[1].response = false
        case 3:
            self.answers!.hasBeenTested = false
            self.questions[1].questions[0].response = false
            self.questions[1].questions[1].response = true
        case 4:
            self.answers!.testResult = true
            self.questions[2].questions[0].response = true
            self.questions[2].questions[1].response = false
        case 5:
            self.answers!.testResult = false
            self.questions[2].questions[0].response = false
            self.questions[2].questions[1].response = true
        default:
            break
        }
    }
    
    /// We are manually setting the questions given the simplicity of this app.  In other cases, we may want to download the questions from a server.
    private func setupQuestions() {
        
        let questionA = QuestionModel(id: 0, sectionHeader: "Are you experiencing symptoms you think may be related to COVID-19?", questions: [Question(id: 0, icon: "checkmark", headline: "Yes", subtitle: "Fever, shortness of breath, and coughing are common symptoms.", response: self.answers!.feelingSick), Question(id: 1, icon: "xmark", headline: "No", subtitle: "No, I am not experiecing symptoms that seem related to COVID-19.", response: !self.answers!.feelingSick)])
        
        let questionB = QuestionModel(id: 1, sectionHeader: "Have you been professionally tested for COVID-19?", questions: [Question(id: 2, icon: "checkmark", headline: "Yes", subtitle: "Yes, I have visitied a testing facility and have been tested using a CDC-approved test.", response: self.answers!.hasBeenTested), Question(id: 3, icon: "xmark", headline: "No", subtitle: "No, I have not been professionally tested for COVID-19.", response: !self.answers!.hasBeenTested)])
        
        let questionC = QuestionModel(id: 2, sectionHeader: "Did you show a positive, confirmed test for COVID-19?", questions: [Question(id: 4, icon: "checkmark", headline: "Yes", subtitle: "Yes, my test was confirmed to show a positive result for COVID-19.", response: false), Question(id: 5, icon: "xmark", headline: "No", subtitle: "No, my test did not show a positive result/I tested negative for COVID-19.", response: true)])
        
        questions.append(contentsOf: [questionA, questionB, questionC])
    }
    
    private func saveAnswers() {
        var myAnswers = self.answers!
        myAnswers.didAnswer = true
        myAnswers.update = Date().timeIntervalSince1970
        defer {
            if let encoded = try? encoder.encode(myAnswers) {
                defaults.set(encoded, forKey: "answers")
            }
        }
        if let savedData = defaults.object(forKey: "answers") as? Data {
            if let loadedData = try? decoder.decode(CovidModel.self, from: savedData) {
                guard loadedData != self.answers else { return }
            }
        }
    }
    
    private func publishAnswer(completion: @escaping (Bool) -> Void) {
        guard let answerSet = self.answers else {
            completion(false)
            return
        }
        let t = try? encoder.encode(answerSet)
        
        let destination = URL(string: "hello.com")!
        let urlconfig = URLSessionConfiguration.default
        urlconfig.timeoutIntervalForResource = 15.0
        urlconfig.timeoutIntervalForRequest = 15.0
        let session = URLSession(configuration: urlconfig)
        
        var request = URLRequest(url: destination)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        t != nil ? request.httpBody = t : nil
        
        updateCancellable = session.dataTaskPublisher(for: request)
            .receive(on: RunLoop.main)
            .map({ $0.response })
            .compactMap({ $0 as? HTTPURLResponse })
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { completed in
                print("Status of answer update:", completed)
                self.updateCancellable?.cancel()
            }, receiveValue: { response in
                switch response.statusCode {
                case 200:
                    completion(true)
                default:
                    completion(false)
                }
            })
    }
}
