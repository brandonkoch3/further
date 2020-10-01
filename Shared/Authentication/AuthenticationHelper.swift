//
//  AuthenticationHelper.swift
//  Futher
//
//  Created by Brandon on 9/17/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation
import AuthenticationServices
import SwiftUI
import Combine

class AuthenticationHelper: ObservableObject {
    
    // MARK: Helpers
    private let appleIDProvider = ASAuthorizationAppleIDProvider()
    private let logger = FurtherLogger(category: "authServices")
    
    // MARK: UI Config
    @Published var hasSavedAppleIDLogin = false
    
    // MARK: Error Handling
    struct LoginError: Error {
        var title: String
        var code: Int
    }
    
    // MARK: Combine
    private var credentialCancellable: AnyCancellable?
    
    init() {
        self.getCredentialState()
    }
    
    public func getCredentialState()  {
        guard let userID = getSavedID() else { return }
        let authenticated = Future<Bool, Error> { promise in
            self.appleIDProvider.getCredentialState(forUserID: userID) { (state, error) in
                if let error = error {
                    promise(.failure(error))
                }
                switch state {
                case .authorized:
                    promise(.success(true))
                case .notFound:
                    promise(.success(false))
                case .revoked:
                    promise(.failure(LoginError(title: "Revoked", code: 203)))
                case .transferred:
                    promise(.failure(LoginError(title: "Transferred", code: 204)))
                default:
                    promise(.failure(LoginError(title: "Unknown", code: 201)))
                }
            }
        }
        
        credentialCancellable = authenticated
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure(let error):
                    self.logger.logger.error("Error occurred while checking auth status: \(error.localizedDescription, privacy: .public)")
                case .finished:
                    break
                }
            }, receiveValue: { (authenticated) in
                if authenticated {
                    self.hasSavedAppleIDLogin = true
                }
            })
        
    }
    
    private func getSavedID() -> String? {
        if let userID = UserDefaults(suiteName: "group.com.bnbmedia.further.contents")?.string(forKey: "userID") {
            return userID
        }
        return nil
    }
    
}
