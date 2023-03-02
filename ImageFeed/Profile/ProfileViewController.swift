
import UIKit
import Kingfisher

class ProfileViewController: UIViewController {
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private let gradientAvatar = CAGradientLayer()
    private let gradientNameLabel = CAGradientLayer()
    private let gradietnLoginLabel = CAGradientLayer()
    private let gradientDescriptionLabel = CAGradientLayer()
    
    //MARK: - Properties
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "Avatar")
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35.0
        return imageView
    }()
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Екатерина Новикова"
        label.font = .systemFont(ofSize: 23, weight: .bold)
        label.textColor = .ypWhite
        return label
    }()
    
    private var loginNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "@ekaterina_nov"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypGray
        return label
    }()
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hello, world!"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypWhite
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "ipad.and.arrow.forward"), for: .normal)
    
        return button
    }()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        
        self.view.backgroundColor = .ypBlack
        
        addSublayers()
        startAnimateGradient()
        
        addSubViews()
        applyConstraints()
        
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main,
                using: { [weak self] _ in
                    guard let self else { return }
                    self.updateAvatar()
                })
        
        updateAvatar()
    }
    
    //MARK: - Objc Methods
    @objc func didTapLogoutButton() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
            OAuth2TokenStorage().token = nil
            WebViewCacheCleaner.clean()
            guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration")}
            let splashViewController = SplashViewController()
            window.rootViewController = splashViewController
        })
        )
        alert.addAction(UIAlertAction(title: "Нет", style: .default, handler: { _ in
            alert.dismiss(animated: true)
        }))
        present(alert, animated: true)
    }
    
    //MARK: - Functions
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
        endAnimateGradients()
    }
    
    private func updateAvatar() {
        guard
            let profileImageUrl = profileImageService.avatarURL,
            let url = URL(string: profileImageUrl)
        else { return }
        let processor = RoundCornerImageProcessor(cornerRadius: 35.0)
        avatarImageView.kf.setImage(with: url, placeholder: UIImage(named: "DefaultAvatar"), options: [.processor(processor)])
    }
    
    private func addSubViews() {
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
    }
    
    private func addSublayers() {
        avatarImageView.layer.addSublayer(gradientAvatar)
        nameLabel.layer.addSublayer(gradientNameLabel)
        loginNameLabel.layer.addSublayer(gradietnLoginLabel)
        descriptionLabel.layer.addSublayer(gradientDescriptionLabel)
    }
    
    private func endAnimateGradients() {
        gradientAvatar.removeFromSuperlayer()
        gradientNameLabel.removeFromSuperlayer()
        gradietnLoginLabel.removeFromSuperlayer()
        gradientDescriptionLabel.removeFromSuperlayer()
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leftAnchor.constraint(equalTo: avatarImageView.leftAnchor),
            
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leftAnchor.constraint(equalTo: loginNameLabel.leftAnchor),
            
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 56),
            logoutButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -26)
        ])
    }
    
    private func startAnimateGradient() {
        animateGradients(gradient: gradientAvatar, size: CGSize(width: 70, height: 70), cornerRadius: 35, keyAnimation: "avatarLocationChange")
        animateGradients(gradient: gradientNameLabel, size: CGSize(width: 223, height: 18), cornerRadius: 9, keyAnimation: "nameLocationChange")
        animateGradients(gradient: gradietnLoginLabel, size: CGSize(width: 89, height: 18), cornerRadius: 9, keyAnimation: "loginLocationGhange")
        animateGradients(gradient: gradientDescriptionLabel, size: CGSize(width: 67, height: 18), cornerRadius: 9, keyAnimation: "descriptionLocationChange")
    }
    
    private func animateGradients(gradient: CAGradientLayer, size: CGSize, cornerRadius: CGFloat, keyAnimation: String) {
        gradient.frame = CGRect(origin: .zero, size: size)
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = cornerRadius
        gradient.masksToBounds = true
        
        let gradientAnimation = CABasicAnimation(keyPath: "locations")
        gradientAnimation.duration = 1.0
        gradientAnimation.repeatCount = .infinity
        gradientAnimation.fromValue = [0, 0.1, 0.3]
        gradientAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientAnimation, forKey: keyAnimation)
    }
    
}
