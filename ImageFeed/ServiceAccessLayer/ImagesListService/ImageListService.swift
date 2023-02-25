import Foundation

final class ImagesListService {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private let urlSession = URLSession.shared
    private var lastTask: URLSessionTask?
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        lastTask?.cancel()
        
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        var request = URLRequest.makeRequest(path: "photos\(nextPage)", httpMethod: "GET")
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<PhotoResult, Error>) in
            guard let self else { return }
            switch result {
            case .success(let photoResult):
                let photo = Photo(result: photoResult)
                self.photos.append(photo)
                
                NotificationCenter.default.post(
                    name:ImagesListService.didChangeNotification,
                    object: self
                    )
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        task.resume()
        lastTask = task
    }
} 
