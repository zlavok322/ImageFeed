import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest
    func code(from url: URL) -> String?
}

class AuthHelper: AuthHelperProtocol {
    
    let configuration: AuthConfiguration
    
    init(configuration: AuthConfiguration = .standart) {
        self.configuration = configuration
    }
    
    func authRequest() -> URLRequest {
        let url = authURL()
        return URLRequest(url: url)
    }
    
    func code(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
    
    func authURL() -> URL {
        var urlComponents = URLComponents(string: AuthConfiguration.standart.authURLString)!
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AuthConfiguration.standart.accessKey),
            URLQueryItem(name: "redirect_uri", value: AuthConfiguration.standart.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: AuthConfiguration.standart.accessScope)
        ]
        
        return urlComponents.url!
    }
}
