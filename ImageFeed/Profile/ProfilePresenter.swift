import Foundation

protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func logout()
    func loadProfileImageURL()
    var profileService: ProfileService { get set }
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    //MARK: - Properties
    weak var view: ProfileViewControllerProtocol?
    
    var profileService = ProfileService.shared
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
            let profileImageURL = ProfileImageService.shared.avatarURL,
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
        OAuth2TokenStorage().token?.removeAll()
        WebViewCacheCleaner.clean()
    }
}
