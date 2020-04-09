//
//  EnvironmentSettings.swift
//  SwiftUIDesignProject
//
//  Created by Brandon on 4/3/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class EnvironmentSettings: NSObject, ObservableObject {
    
    // Config
    @Published var env = environmentModel(allowDetection: true, allowQuestions: true, allowStories: true)
    
    // Helpers
    let decoder = JSONDecoder()
    let defaults = UserDefaults.standard
    
    // Models
    struct environmentModel: Codable {
        var allowDetection: Bool
        var allowQuestions: Bool
        var allowStories: Bool
    }
    
    // Combine
    var updateCancellable: AnyCancellable?
    
    override init() {
        super.init()
        
        if let savedData = defaults.object(forKey: "answers") as? Data {
            if let loadedData = try? decoder.decode(environmentModel.self, from: savedData) {
                self.env = loadedData
            }
        }
        
        updateEnvironment() { response in }
    }
    
    private func updateEnvironment(completion: @escaping (Bool) -> Void) {
        let destination = URL(string: "https://mlv3dsc5tc.execute-api.us-east-1.amazonaws.com/features")!
        let urlconfig = URLSessionConfiguration.default
        urlconfig.timeoutIntervalForResource = 15.0
        urlconfig.timeoutIntervalForRequest = 15.0
        let session = URLSession(configuration: urlconfig)
        
        var request = URLRequest(url: destination)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        updateCancellable = session.dataTaskPublisher(for: request)
            .receive(on: RunLoop.main)
            .map({ $0.data })
            .decode(type: environmentModel.self, decoder: decoder)
            .replaceError(with: self.env)
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { completed in
                self.updateCancellable?.cancel()
            }, receiveValue: { response in
                self.env = response
            })
    }
}
