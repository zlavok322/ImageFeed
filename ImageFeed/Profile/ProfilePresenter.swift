import Foundation

public protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func logout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    //MARK: - Properties
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        checkProfile()
        loadProfileImageURL()
    }
    
    func checkProfile() {
        if let profile = profileService.profile {
            view?.updateProfileDetails(profile: profile)
        }
    }
    
    func loadProfileImageURL() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main,
                using: { [weak self] _ in
                    guard let self else { return }
                    self.view?.updateAvatar(url: url)
                    self.checkProfile()
                })
        view?.updateAvatar(url: url)
    }
    
    func logout() {
        OAuth2TokenStorage().token = nil
        WebViewCacheCleaner.clean()
    }
}
