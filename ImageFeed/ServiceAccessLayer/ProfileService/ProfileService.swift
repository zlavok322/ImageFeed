import Foundation

public protocol ProfileServiceProtocol {
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void)
    var profile: Profile? { get }
}

public final class ProfileService {
    static let shared = ProfileService()

    private let urlSession = URLSession.shared
    private var lastTask: URLSessionTask?
//    private var tempProfile: Profile?
    private(set) var profile: Profile?

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        lastTask?.cancel()

        var request = URLRequest.makeRequest(path: "me", httpMethod: "GET")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            switch result {
            case .success(let body):
                let profile = Profile(result: body)
                self.profile = profile
                completion(.success(profile))
            case .failure:
                completion(.failure(NetworkError.urlSessionError))
            }
        }
        task.resume()
        self.lastTask = task
    }
}
