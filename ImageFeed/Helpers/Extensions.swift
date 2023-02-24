import Foundation

private enum NetworkError: Error {
    case httpStatusCode
    case urlRequestError(Error)
    case urlSessionError
    case notDecodeJson
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            if let response = response as? HTTPURLResponse, response.statusCode < 200 || response.statusCode >= 300 {
                completion(.failure(NetworkError.httpStatusCode))
            }
            guard let data = data else {
                return
            }
            do {
                let JSONtoStruct = try JSONDecoder().decode(T.self, from: data)
                completion(.success(JSONtoStruct))
            } catch {
                completion(.failure(NetworkError.notDecodeJson))
            }
        })
        return task
    }
}

extension URLRequest {
    static func makeRequest(
        path: String,
        httpMethod: String,
        baseURL: URL = Constants.defaultBaseURL
    ) -> URLRequest {
        var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
        request.httpMethod = httpMethod
        return request
    }
}
