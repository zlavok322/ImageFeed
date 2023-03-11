import Foundation

let AccessKey  = "xvaZx63_TJ3MEWMFEzR9L4HDEuapt4_NSqrje2IJ5-g"
let SecretKey = "-FXOn_lAlxUVn7qYGFuubWGy2F7XZ7gBGZ7hEq9q33g"
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope = "public+read_user+write_likes"

let DefaultBaseURL = URL(string: "https://api.unsplash.com/")!
let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    static var standart: AuthConfiguration {
        return AuthConfiguration(accessKey: AccessKey, secretKey: SecretKey, redirectURI: RedirectURI, accessScope: AccessScope, defaultBaseURL: DefaultBaseURL, authURLString: UnsplashAuthorizeURLString)
    }
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, authURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
}

public struct NoReply: Decodable {}
