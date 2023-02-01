
import Foundation

protocol OAuth2TokenStorageProtocol {
    var token: String? {get set}
}
final class OAuth2TokenStorage: OAuth2TokenStorageProtocol {
    private enum Keys: String {
        case token
    }
    
    private let userDefaults = UserDefaults.standard
    
    var token: String? {
        get {
            return userDefaults.string(forKey: Keys.token.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.token.rawValue)
        }
    }
}
