
import Foundation
import SwiftKeychainWrapper

protocol OAuth2TokenStorageProtocol {
    var token: String? {get set}
}

final class OAuth2TokenStorage: OAuth2TokenStorageProtocol {
    private enum Keys: String {
        case token
    }
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: Keys.token.rawValue)
        }
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: Keys.token.rawValue)
            } else {
                KeychainWrapper.standard.removeObject(forKey: Keys.token.rawValue)
            }
        }
    }
}
