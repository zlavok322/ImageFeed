
import UIKit

final class SplashViewController: UIViewController {

    //MARK: - Properties
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    let tokenStorage = OAuth2TokenStorage()

    //MARK: - LifeCicle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if tokenStorage.token != nil {
            print("В памяти есть токен \(tokenStorage.token!)")
            switchToTabBarController()
        } else {
            print("Токена нет, переключаем на аутентификацию")
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }

    //MARK: - Methods
    func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration")}
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

//MARK: - Extensions
extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")}
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        switchToTabBarController()
    }
}
