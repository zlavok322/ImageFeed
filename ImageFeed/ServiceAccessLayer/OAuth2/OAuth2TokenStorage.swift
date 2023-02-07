
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
            UserDefaults.standard.string(forKey: Keys.token.rawValue)
        }
        set {
            if let token = newValue {
                UserDefaults.standard.set(token, forKey: Keys.token.rawValue)
            } else {
                UserDefaults.standard.removeObject(forKey: Keys.token.rawValue)
            }
        }
    }
}
