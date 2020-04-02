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
            self.answers = CovidModel(id: self.myID, feelingSick: false, hasBeenTested: false, testResult: false, update: Date().timeIntervalSince1970)
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
    
    /// We are manually setting the questions given the simplicity of this app.  In other cases, we may want to download the questions from a server.
    private func setupQuestions() {
        let questionA = QuestionModel(sectionHeader: "Are you experiencing symptoms you think may be related to COVID-19?", question: [Question(text: "Fever, shortness of breath, and difficulty breathing are common symptoms.", response: false), Question(text: "I am not experiencing symptoms that seem related to COVID-19.", response: true)])
        
        let questionB = QuestionModel(sectionHeader: "Have you been professionally tested for COVID-19?", question: [Question(text: "Yes, I have visitied a testing facility and have been tested using a CDC-approved test.", response: false), Question(text: "No, I have not been professionally tested for COVID-19.", response: true)])
        
        let questionC = QuestionModel(sectionHeader: "Did you show a positive, confirmed test for COVID-19?", question: [Question(text: "Yes, my test was confirmed to show a positive result for COVID-19.", response: false), Question(text: "No, my test did not show a positive result/I tested negative for COVID-19.", response: true)])
        
        questions.append(contentsOf: [questionA, questionB, questionC])
    }
    
    private func saveAnswers() {
        defer {
            if let encoded = try? encoder.encode(self.answers) {
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
