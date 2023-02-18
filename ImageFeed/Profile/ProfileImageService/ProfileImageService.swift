import Foundation

enum TokenError: Error {
    case emptyToken
}

protocol ProfileImageServiceProtocol {
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void)
    var avatarURL: String? { get }
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private let storage: OAuth2TokenStorage = OAuth2TokenStorage()
    private let urlSession = URLSession.shared
    private var tempAvatarURL: String?
    
    var avatarURL: String? {
        get {
            return tempAvatarURL
        }
        set {
            tempAvatarURL = newValue
        }
    }
    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<UserResult, Error>) -> Void) {
        if let token = storage.token {
            var request = URLRequest.makeRequest(path: "users/\(username)", httpMethod: "GET")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
                guard let self else { return }
                switch result {
                case .success(let userResult):
                    self.avatarURL = userResult.profileImage.medium
                    
                    if let avatarURL = self.avatarURL {
                        NotificationCenter.default.post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": avatarURL]
                        )
                    }
                    
                    completion(.success(userResult))
                    print("Получили картинку Получили картинку Получили картинкуПолучили картинку Получили картинку Получили картинку")
                case .failure:
                    print("НЕ ПОЛУЧИЛИ КАРТИНКУ НЕ ПОЛУЧИЛИ КАРТИНКУ НЕ ПОЛУЧИЛИ КАРТИНКУ НЕ ПОЛУЧИЛИ КАРТИНКУ НЕ ПОЛУЧИЛИ КАРТИНКУ НЕ ПОЛУЧИЛИ КАРТИНКУ НЕ ПОЛУЧИЛИ КАРТИНКУ")
                }
            }
            task.resume()
        } else {
            completion(.failure(TokenError.emptyToken))
            print("НЕ РАБОТАЕТ ТОКЕН")
        }
    }
}
