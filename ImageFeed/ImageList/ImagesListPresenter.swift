import Foundation

public protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    var imagesListService: ImagesListService { get set }
    func viewDidLoad()
    func fetchPhotosNextPage()
}

final class ImageListPresenter: ImagesListPresenterProtocol {
    
    weak var view: ImagesListViewControllerProtocol?
    var imagesListService = ImagesListService()
    private var imageListServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        imagesListService.fetchPhotosNextPage()
        
        imageListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                
                let photos = self.imagesListService.photos
                self.view?.updateTableViewAnimated(photos: photos)
            }
    }

    internal func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
}
