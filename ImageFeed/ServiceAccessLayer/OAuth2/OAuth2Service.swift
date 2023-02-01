import Foundation
class OAuth2Service {

    private enum NetworkError: Error {
        case codeError
    }

    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        var urlComponents = URLComponents(string: Constants.unsplashAuthorizeURLString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]

        let url = urlComponents.url!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let response = response as? HTTPURLResponse,
                   response.statusCode < 200 || response.statusCode >= 300 {
                    completion(.failure(NetworkError.codeError))
                    return
                }

                guard let data = data else { return }

                do {
                    let jsonData = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(jsonData.accessToken))
                } catch let error {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
