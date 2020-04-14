//
//  StoriesController.swift
//  SwiftUIDesignProject
//
//  Created by Brandon on 4/2/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class StoriesController: ObservableObject {
    
    @Published var stories = [CovidStory]()
    private var interactions = [PersonModel]()
    
    // Helpers
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let defaults = UserDefaults.standard
    let notifications = PersonNotifications()
    #if !os(watchOS)
    var keyValStore = NSUbiquitousKeyValueStore()
    #endif
    
    // Combine
    var dataCancellable: AnyCancellable?
    var updateTimer: AnyCancellable?
    
    init() {
        
        #if !os(watchOS)
        if let savedData = keyValStore.object(forKey: "stories") as? Data {
            if let loadedData = try? decoder.decode([CovidStory].self, from: savedData) {
                self.stories = loadedData
            }
        }
        #endif
        
        if stories.isEmpty {
            if let savedData = defaults.object(forKey: "stories") as? Data {
                if let loadedData = try? decoder.decode([CovidStory].self, from: savedData) {
                    self.stories = loadedData
                }
            }
        }
        
        self.stories.sort(by: { $0.dateGathered > $1.dateGathered })
        
        #if !os(watchOS)
        if let savedData = keyValStore.object(forKey: "interactions") as? Data {
            if let loadedData = try? decoder.decode([PersonModel].self, from: savedData) {
                self.interactions = loadedData
            }
        }
        #endif
        
        if interactions.isEmpty {
            if let savedData = defaults.object(forKey: "interactions") as? Data {
                if let loadedData = try? decoder.decode([PersonModel].self, from: savedData) {
                    self.interactions = loadedData
                }
            }
        }

        print("STORIES:", self.stories)
        
        self.update() { response in }
        
        updateTimer = Timer.publish(every: 600.0, tolerance: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.update() { response in }
            }
    }
    
    public func update(completion: @escaping (Bool) -> Void) {
        self.updateStories() { response in
            if let yesterdayDate = Date().yesterdayCheckDate() {
                if !self.stories.contains(where: { $0.displayDate == Date().yesterdayAsString() }) {
                    self.updateStories(date: yesterdayDate) { response in }
                }
            }
        }
    }
    
    private func updateStories(date: Date? = Date(), completion: @escaping (Bool) -> Void) {
        let nowDate = date!
        let dateFormatter = DateFormatter()
        //dateFormatter.locale = NSLocale.current
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let strDate = dateFormatter.string(from: nowDate)
        
        guard !self.stories.contains(where: { $0.displayDate == strDate }) else {
            completion(true)
            return
        }
        
        dateFormatter.dateFormat = "HH"
        guard let hourString = Int(dateFormatter.string(from: nowDate)) else { return }
        guard hourString >= 19 else { return }
        
        var todayStory = CovidStory(id: UUID(), displayDate: strDate, dateGathered: Date().timeIntervalSince1970, positiveContacts: [], didSendNotification: false)
        
        self.downloadData() { response in
            if let data = response {
                for (index, id) in self.interactions.enumerated() {
                    if data.contains(where: { $0.id == id.personUUID && $0.testResult && !id.hasReceivedNotification }) {
                        todayStory.positiveContacts.append(id.personUUID)
                        self.interactions[index].hasReceivedNotification = true
                    }
                }
                
                self.notifications.sendNotification()
                todayStory.didSendNotification = true
                self.stories.append(todayStory)
                
                if let encoded = try? self.encoder.encode(self.stories) {
                    self.defaults.set(encoded, forKey: "stories")
                    #if !os(watchOS)
                    self.keyValStore.set(encoded, forKey: "stories")
                    self.keyValStore.synchronize()
                    #endif
                }
                
                self.stories.sort(by: { $0.dateGathered > $1.dateGathered })
                
                completion(true)
                return
                
            } else {
                completion(false)
                return
            }
        }
    }
    
    private func downloadData(completion: @escaping ([CovidModel]?) -> Void) {
        let destination = URL(string: "https://mlv3dsc5tc.execute-api.us-east-1.amazonaws.com/data")!
        let urlconfig = URLSessionConfiguration.default
        urlconfig.timeoutIntervalForResource = 15.0
        urlconfig.timeoutIntervalForRequest = 15.0
        let session = URLSession(configuration: urlconfig)
        
        var request = URLRequest(url: destination)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        dataCancellable = session.dataTaskPublisher(for: request)
            .receive(on: RunLoop.main)
            .map({ $0.data })
            .decode(type: [CovidModel].self, decoder: decoder)
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { completed in
                print("Status of download data update:", completed)
                self.dataCancellable?.cancel()
            }, receiveValue: { response in
                if !response.isEmpty {
                    completion(response)
                    return
                } else {
                    print("No data was available to download.")
                    completion(nil)
                }
            })
    }
    
}
