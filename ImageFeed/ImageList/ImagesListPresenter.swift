import Foundation

public protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var imagesListService: ImagesListService { get set }
    func fetchPhotosNextPage()
    func viewDidLoad()
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    var imagesListService = ImagesListService()
    weak var view: ImagesListViewControllerProtocol?
    private var imageListServiceObserver: NSObjectProtocol?
    
    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func viewDidLoad() {
        imagesListService.fetchPhotosNextPage()
        
        imageListServiceObserver = NotificationCenter.default
            .addObserver(forName: ImagesListService.didChangeNotification,
                         object: nil,
                         queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                let photos = self.imagesListService.photos
                self.view?.updateTableViewAnimated(photos: photos)
            }
    }
    
}
