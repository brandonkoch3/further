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
    @Published var answers: WellnessModel?
    private var myID: String = ""
    
    // Combine
    var answerSubscriber: AnyCancellable?
    var publishSubscriber: AnyCancellable?
    var updateCancellable: AnyCancellable?
    
    // Helpers
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let defaults = UserDefaults.standard
    #if !os(watchOS)
    var keyValStore = NSUbiquitousKeyValueStore()
    #endif
    
    init() {
        
        if let myID = UserDefaults.standard.string(forKey: "deviceID") {
            self.myID = myID
        }
        
        #if !os(watchOS)
        if let savedData = keyValStore.object(forKey: "answers") as? Data {
            if let loadedData = try? decoder.decode(WellnessModel.self, from: savedData) {
                self.answers = loadedData
            }
        }
        #endif
        
        if self.answers == nil {
            if let savedData = defaults.object(forKey: "answers") as? Data {
                if let loadedData = try? decoder.decode(WellnessModel.self, from: savedData) {
                    self.answers = loadedData
                }
            }
        }
        
        if self.answers == nil {
            self.answers = WellnessModel(id: self.myID, feelingSick: false, hasBeenTested: false, testResult: false, lastUpdate: Date().timeIntervalSince1970)
        }
        
        answerSubscriber = $answers
            .receive(on: RunLoop.main)
            .sink(receiveValue: { model in
                self.saveAnswers()
            })
        
        publishSubscriber = $answers
            .receive(on: RunLoop.main)
            .debounce(for: 2.0, scheduler: RunLoop.main)
            .sink(receiveValue: { positive in
                self.publishAnswer() { update in }
            })
        
        setupQuestions()
        
    }
    
    public func updateAnswers(questionID: Int, response: Bool) {
        print("Updating:", questionID, "to", response)
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
        
        let questionA = QuestionModel(id: 0, sectionHeader: "Are you feeling unwell or different from how you usually feel?", questions: [Question(id: 0, icon: "checkmark", headline: "Yes", subtitle: "I am not quite feeling like myself these days.", response: self.answers!.feelingSick), Question(id: 1, icon: "xmark", headline: "No", subtitle: "I am feeling just fine.", response: !self.answers!.feelingSick)])
        
        let questionB = QuestionModel(id: 1, sectionHeader: "Did you visit a professional for help related to how you are feeling?", questions: [Question(id: 2, icon: "checkmark", headline: "Yes", subtitle: "I visited a professional or specialist.", response: self.answers!.hasBeenTested), Question(id: 3, icon: "xmark", headline: "No", subtitle: "I did not visit a professional or specialist.", response: !self.answers!.hasBeenTested)])
        
        let questionC = QuestionModel(id: 2, sectionHeader: "Was a professional able to positively confirm why you are feeling ill?", questions: [Question(id: 4, icon: "checkmark", headline: "Yes", subtitle: "A professional confirmed a result/reason for my symptoms.", response: self.answers!.testResult), Question(id: 5, icon: "xmark", headline: "No", subtitle: "A professional did not positively confirm a reason for my symptoms.", response: !self.answers!.testResult)])
        
        questions.append(contentsOf: [questionA, questionB, questionC])
    }
    
    private func saveAnswers() {
        var myAnswers = self.answers!
        myAnswers.id = self.myID
        myAnswers.lastUpdate = Date().timeIntervalSince1970
        defer {
            if let encoded = try? encoder.encode(myAnswers) {
                #if !os(watchOS)
                keyValStore.set(encoded, forKey: "answers")
                #endif
                defaults.set(encoded, forKey: "answers")
            }
        }
        if let savedData = defaults.object(forKey: "answers") as? Data {
            if let loadedData = try? decoder.decode(WellnessModel.self, from: savedData) {
                guard loadedData != myAnswers else { return }
            }
        }
    }
    
    private func publishAnswer(completion: @escaping (Bool) -> Void) {
        guard var answerSet = self.answers else {
            completion(false)
            return
        }
        answerSet.id = self.myID
        answerSet.lastUpdate = Date().timeIntervalSince1970
        print("About to publish:", answerSet)
        let t = try? encoder.encode(answerSet)
        
        let destination = URL(string: "https://mlv3dsc5tc.execute-api.us-east-1.amazonaws.com/health")!
        let urlconfig = URLSessionConfiguration.default
        urlconfig.timeoutIntervalForResource = 15.0
        urlconfig.timeoutIntervalForRequest = 15.0
        let session = URLSession(configuration: urlconfig)
        
        var request = URLRequest(url: destination)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.httpBody = t
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        updateCancellable = session.dataTaskPublisher(for: request)
            .receive(on: RunLoop.main)
            .map({ $0.response })
            .compactMap({ $0 as? HTTPURLResponse })
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { completed in
                print("COMPLETION:", completed)
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

struct QuestionsController_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
