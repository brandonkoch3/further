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
import MapKit
#if canImport(WidgetKit)
import WidgetKit
#endif

class PersonInfoController: ObservableObject {
    
    // MARK: Data
    @Published var personInfo: PersonInfoModel!
    var baseURL: String?
    var appType: EnvironmentSettings.appType?
    
    // MARK: Helpers
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    let defaults = UserDefaults(suiteName: "group.com.bnbmedia.further.contents")
    let qrGenerator = QRCodeGenerator()
    let mapHelper = MapHelper()
    
    // MARK: QR Code
    @Published public var qrCode: UIImage = UIImage(systemName: "plus.viewfinder")!
    
    #if !os(watchOS)
    var keyValStore = NSUbiquitousKeyValueStore()
    #endif
    
    // MARK: Combine
    var qrCancellable: AnyCancellable?
    var mapCancellable: AnyCancellable?
    var editorCancellable: AnyCancellable?
    var addressCancellable: AnyCancellable?
    
    init() {
        
        // Load person info
        if let infoModel = loadPersonInfo() {
            self.personInfo = infoModel
            if let qr = self.qrGenerator.userQRCode() {
                self.qrCode = qr
            }
            self.setupListeners()
        } else {
            
            // Generate person info
            self.personInfo = PersonInfoModel(id: UUID().uuidString, name: "", email: "", phone: "", address: "", unit: "", addressZip: "")
            
            // Save locally
            savePersonInfo(data: self.personInfo!)
            
            // Setup listeners
            self.setupListeners()
        }
    }
    
    private func setupListeners() {
        
        // Editor Listener
        editorCancellable = $personInfo
            .receive(on: RunLoop.main)
            .sink(receiveValue: { (person) in
                self.savePersonInfo(data: person!)
            })
        
        addressCancellable = $personInfo
            .receive(on: RunLoop.main)
            .filter{ $0?.address != "" }
            .compactMap { $0?.address }
            .sink(receiveValue: { (address) in
                self.mapHelper.search(for: address)
            })
        
        // QR Code Listener
        qrCancellable = qrGenerator.qrCompletionPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { (qrURL) in
                if let qr = self.qrGenerator.userQRCode() {
                    self.qrCode = qr
                }
            })
        
        // Map Listener
        mapCancellable = mapHelper.$selectedItem
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [self] (item) in
                if let addressOne = item?.thoroughfare {
                    self.personInfo.address = addressOne
                    if let addressTwo = item?.subThoroughfare {
                        self.personInfo.address = addressTwo + " " + addressOne
                    }
                }
                if let zip = item?.postalCode {
                    self.personInfo.addressZip = zip
                    if let city = item?.locality {
                        if let state = item?.administrativeArea {
                            self.personInfo.addressZip = city + ", " + state + " " + zip
                        }
                    }
                }
            })
        
    }
    
    public func generateQRCode() {
        
        // Load environmental data
        loadEnvironmentInfo()
        
        // Generate QR Code
        guard let type = self.appType, let url = baseURL, let id = self.personInfo?.id else {
            return
            
        }
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
        
        print("Check person info")
        
        // Check Key-Value Storage for person info
        #if !os(watchOS)
        if let savedData = keyValStore.object(forKey: "personInfoModel") as? Data {
            if let loadedData = try? decoder.decode(PersonInfoModel.self, from: savedData) {
                print("Returning person info", loadedData)
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
        updateWidget()
    }
    
    public func saveAndValidate(data: PersonInfoModel) -> Bool {
        guard data.name != "",
              data.phone != "",
              data.phone.isValidPhone(),
              data.email != "",
              data.email.isValidEmail(),
              data.address != "",
              data.addressZip != ""
              
        else { return false }
        
        return true
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
