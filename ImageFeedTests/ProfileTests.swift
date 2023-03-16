@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        _ = viewController.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsUpdates() {
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        let profileServiceDummy = ProfileServiceDummy()
        let profileImageServiceDummy = ProfileImageServiceDummy()
        
//        let expectation = expectation(description: "Test completed")
        
        profileServiceDummy.fetchProfile("") { result in
            switch result {
            case .success:
                profileImageServiceDummy.fetchProfileImageURL(username: "") { _ in
                    presenter.viewDidLoad()
                    
                    XCTAssertTrue(viewController.updateProfileDetailsCalled)
                    XCTAssertTrue(viewController.updateAvatarCalled)
                    
//                    expectation.fulfill()
                }
            case .failure:
                XCTFail()
            }
        }
        
//        waitForExpectations(timeout: 10)
    }
    
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ImageFeed.ProfilePresenterProtocol?

    var updateAvatarCalled = false
    var updateProfileDetailsCalled = false
    
    func updateAvatar(url: URL) {
        updateAvatarCalled = true
    }
    
    func updateProfileDetails(profile: ImageFeed.Profile) {
        updateProfileDetailsCalled = true
    }
}

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    
    var profileService: ImageFeed.ProfileService = ImageFeed.ProfileService()
    var viewDidLoadCalled: Bool = false
    var view: ImageFeed.ProfileViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func logout() {
        
    }
    
    func loadProfileImageURL() {
        
    }
}

final class ProfileServiceDummy: ProfileServiceProtocol {
    func fetchProfile(_ token: String, completion: @escaping (Result<ImageFeed.Profile, Error>) -> Void) {
        let profile = Profile(result: ProfileResult(username: "", firstName: "", lastName: "", bio: ""))
        completion(.success(profile))
    }
    var profile: ImageFeed.Profile?
}

final class ProfileImageServiceDummy: ProfileImageServiceProtocol {
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<ImageFeed.UserResult, Error>) -> Void) {}
    
    var avatarURL: String?
}
