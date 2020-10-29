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
    var publishCancellable: AnyCancellable?
    
    // MARK: Validators
    @Published var validName = false
    @Published var validPhone = false
    @Published var validEmail = false
    @Published var validAddress = false
    @Published var validated = false
    
    init() {
        
        // Load person info
        if let infoModel = loadPersonInfo() {
            self.personInfo = infoModel
            print("Have person info")
            if let qr = self.qrGenerator.userQRCode() {
                self.qrCode = qr
            }
        } else {
            
            // Generate person info
            self.personInfo = PersonInfoModel(id: UUID().uuidString, name: "", email: "", phone: "", address: "", unit: "", addressZip: "")
            
            print("need to gfenrate qr code")
            self.generateQRCode()
            if let qr = self.qrGenerator.userQRCode() {
                self.qrCode = qr
            }
            
            // Save locally
            savePersonInfo(data: self.personInfo!)
        }
        
        // Setup listeners
        self.setupListeners()
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
        
        print("About to generate QR code")
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
    
    public func validate() -> Bool {
        self.validName = self.personInfo.name.isValidName()
        self.validPhone = self.personInfo.phone.isValidPhone()
        self.validEmail = self.personInfo.email.isValidEmail()
        self.validAddress = self.personInfo.address != "" && self.personInfo.addressZip != ""
        self.validated = self.validName && self.validPhone && self.validEmail && self.validAddress
        return self.validated
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
        savePersonInfoLocally(data: data)

        updateWidget()
    }
    
    public func savePressed() {
        savePersonInfoRemotely(data: self.personInfo) { response in
            
        }
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
    
    public func shareInteraction(vendorID: String, completion: @escaping (Bool) -> Void) {
        let userID = self.personInfo.id
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion(true)
        }
    }
    
    private func savePersonInfoRemotely(data: PersonInfoModel, completion: @escaping (Bool) -> Void) {
        let t = try? encoder.encode(self.personInfo)
        let destination = URL(string: "https://someapi.com")!
        let urlconfig = URLSessionConfiguration.default
        urlconfig.timeoutIntervalForResource = 15.0
        urlconfig.timeoutIntervalForRequest = 15.0
        let session = URLSession(configuration: urlconfig)
        
        var request = URLRequest(url: destination)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.httpBody = t
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        publishCancellable = session.dataTaskPublisher(for: request)
            .receive(on: RunLoop.main)
            .map({ $0.response })
            .compactMap({ $0 as? HTTPURLResponse })
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { completed in
                self.publishCancellable?.cancel()
            }, receiveValue: { response in
                switch response.statusCode {
                case 200:
                    completion(true)
                default:
                    completion(false)
                }
            })
    }
    
    private func updateWidget() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: "com.bnbmedia.furtherstats")
        #endif
    }
}
