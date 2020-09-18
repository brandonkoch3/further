//
//  PersonInfoController.swift
//  Futher
//
//  Created by Brandon on 9/10/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
#if canImport(WidgetKit)
import WidgetKit
#endif

class PersonInfoController: ObservableObject {
    
    // MARK: Data
    @Published var personInfo: PersonInfoModel?
    var baseURL: String?
    var appType: EnvironmentSettings.appType?
    
    // MARK: Editable Data
    @Published var name: String = ""
    @Published var phone: String = ""
    @Published var email: String = ""
    @Published var address: String = ""
    
    // MARK: Helpers
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    let defaults = UserDefaults(suiteName: "group.com.bnbmedia.further.contents")
    let qrGenerator = QRCodeGenerator()
    
    // MARK: QR Code
    @Published public var qrCode: UIImage = UIImage(systemName: "plus.viewfinder")!
    
    #if !os(watchOS)
    var keyValStore = NSUbiquitousKeyValueStore()
    #endif
    
    // MARK: Combine
    var qrCancellable: AnyCancellable?
    var editorCancellables = Set<AnyCancellable>()
    
    init() {
        
        // Load person info
        if let infoModel = loadPersonInfo() {
            self.personInfo = infoModel
            if let qr = self.qrGenerator.userQRCode() {
                self.qrCode = qr
            }
        } else {
            
            // Generate person info
            self.personInfo = PersonInfoModel(id: UUID().uuidString, name: nil, email: nil, phone: nil, address: nil, qrCodePath: nil)
            
            // Save locally
            savePersonInfo(data: self.personInfo!)
            
            // Setup listener
            qrCancellable = qrGenerator.qrCompletionPublisher
                .receive(on: RunLoop.main)
                .sink(receiveValue: { (qrURL) in
                    if let qr = self.qrGenerator.userQRCode() {
                        self.qrCode = qr
                    }
                })
        }
        
        // Setup listener
            $name
            .receive(on: RunLoop.main)
            .sink { (n) in
                guard self.personInfo != nil else { return }
                self.personInfo!.name = n
                self.savePersonInfo(data: self.personInfo!)
            }
            .store(in: &editorCancellables)
        
            $phone
            .receive(on: RunLoop.main)
            .sink { (p) in
                guard self.personInfo != nil else { return }
                self.personInfo!.phone = p
                self.savePersonInfo(data: self.personInfo!)
            }
            .store(in: &editorCancellables)
        
            $email
            .receive(on: RunLoop.main)
            .sink { (e) in
                guard self.personInfo != nil else { return }
                self.personInfo!.email = e
                self.savePersonInfo(data: self.personInfo!)
            }
            .store(in: &editorCancellables)
        
            $address
            .receive(on: RunLoop.main)
            .sink { (a) in
                guard self.personInfo != nil else { return }
                self.personInfo!.address = a
                self.savePersonInfo(data: self.personInfo!)
            }
            .store(in: &editorCancellables)
        
            
    }
    
    public func generateQRCode() {
        
        // Load environmental data
        loadEnvironmentInfo()
        print("loaded environment data")
        
        // Generate QR Code
        guard let type = self.appType, let url = baseURL, let id = self.personInfo?.id else { return }
        qrGenerator.buildQRCode(appType: type, uniqueID: id, baseURL: url)
    }
    
    private func loadEnvironmentInfo() {
        if let base = defaults!.string(forKey: "baseURL") {
            self.baseURL = base
        }
        if let savedData = defaults!.object(forKey: "appType") as? Int {
            if let appType = EnvironmentSettings.appType(rawValue: savedData) {
                self.appType = appType
            }
        }
    }
    
    private func loadPersonInfo() -> PersonInfoModel? {
        
        // Check Key-Value Storage for person info
        #if !os(watchOS)
        if let savedData = keyValStore.object(forKey: "personInfoModel") as? Data {
            if let loadedData = try? decoder.decode(PersonInfoModel.self, from: savedData) {
                return loadedData
            }
        }
        #endif
        
        // Check local storage for person info
        if self.personInfo == nil {
            if let savedData = defaults!.object(forKey: "personInfoModel") as? Data {
                if let loadedData = try? decoder.decode(PersonInfoModel.self, from: savedData) {
                    return loadedData
                }
            }
        }
        
        return nil
    }
    
    public func savePersonInfo(data: PersonInfoModel) {
        print("saving person info:", data)
        savePersonInfoLocally(data: data)
        savePersonInfoRemotely(data: data) { (response) in
            //
        }
        guard data.qrCodePath != nil else { return }
        updateWidget()
    }
    
    private func savePersonInfoLocally(data: PersonInfoModel) {
        if let encoded = try? encoder.encode(data) {
            defaults!.set(encoded, forKey: "personInfoModel")
            #if !os(watchOS)
            keyValStore.set(encoded, forKey: "personInfoModel")
            keyValStore.synchronize()
            #endif
        }
    }
    
    private func savePersonInfoRemotely(data: PersonInfoModel, completion: @escaping (Bool) -> Void) {
        // TODO: Implement
    }
    
    private func updateWidget() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: "com.bnbmedia.furtherstats")
        #endif
    }
}
