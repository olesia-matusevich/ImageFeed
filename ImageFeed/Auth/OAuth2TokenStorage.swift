//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Alesia Matusevich on 03/01/2025.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case token = "AuthToken"
    }
    
    var token: String? {
        get {
            //storage.string(forKey: Keys.token.rawValue) ?? nil
            let token: String? = KeychainWrapper.standard.string(forKey: Keys.token.rawValue)
            return token
        }
        set {
            //storage.set(newValue, forKey: Keys.token.rawValue)
            guard let token = newValue else {return}
            let isSuccess = KeychainWrapper.standard.set(token, forKey: Keys.token.rawValue)
            guard isSuccess else {
                print("[OAuth2TokenStorage]: error saving token")
                return
            }
        }
    }
    func removeToken(){ //для проверки авторизации
        let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: Keys.token.rawValue)
    }
}
