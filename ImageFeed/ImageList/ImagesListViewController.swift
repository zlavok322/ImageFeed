import UIKit
import Kingfisher

 protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    var photos: [Photo] { get set }
    func updateTableViewAnimated(photos: [Photo])
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
//MARK: - Properties
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    private var imageListServiceObserver: NSObjectProtocol?
    var presenter: ImagesListPresenterProtocol?
    var photos: [Photo] = []
    
    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        self.presenter?.view = self
    }
   
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.YYYY"
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    //MARK: - Outlets
    @IBOutlet private var tableView: UITableView!
    
    //MARK: - LyfeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        imageListService.fetchPhotosNextPage()
//        photos = imagesListService.photos
        presenter?.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    //MARK: - Private function
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let gradientCell = CAGradientLayer()
        let url = URL(string: photos[indexPath.row].thumbImageURL)
        cell.imageViewCell.layer.addSublayer(gradientCell)
        
        gradientCell.frame = CGRect(origin: .zero, size: CGSize(width: cell.imageViewCell.frame.width, height: cell.imageViewCell.frame.height))
        gradientCell.locations = [0, 0.1, 0.3]
        gradientCell.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradientCell.startPoint = CGPoint(x: 0, y: 0.5)
        gradientCell.endPoint = CGPoint(x: 1, y: 0.5)
        gradientCell.cornerRadius = 16
        gradientCell.masksToBounds = true

        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradientCell.add(gradientChangeAnimation, forKey: "cellLocationChange")
        
        cell.imageViewCell.kf.indicatorType = .activity
        cell.imageViewCell.kf.setImage(with: url, placeholder: UIImage(named: "Stub")) { _ in
            gradientCell.removeFromSuperlayer()
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        cell.dateLabel.text = dateFormatter.string(from: photos[indexPath.row].createdAt ?? Date())
    }
    
    
    func updateTableViewAnimated(photos: [Photo]) {
        let oldCount = self.photos.count
        let newCount = photos.count
        self.photos = photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController else { return }
            guard let indexPath = sender as? IndexPath else { return }
            let urlString = URL(string: photos[indexPath.row].largeImageURL)
            viewController.urlImage = urlString
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

//MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }
}

//MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
    //вызывается прямо перед тем, как ячейка таблицы будет показана на экране
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
//            imageListService.fetchPhotosNextPage()
            presenter?.fetchPhotosNextPage()
        }
    }
}

//MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
                
        UIBlockingProgressHUD.show()
        presenter?.imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success:
                self.photos = self.presenter?.imagesListService.photos ?? []
                cell.setIsLiked(isLiked: !photo.isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                print(error)
                self.showAlert()
            }
        }
    }
    
    private func showAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message:"Не удалось войти в систему»",
            preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "ok", style: .cancel, handler: { action in })
        alert.addAction(alertAction)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.present(alert, animated: true)
        }
    }
}
