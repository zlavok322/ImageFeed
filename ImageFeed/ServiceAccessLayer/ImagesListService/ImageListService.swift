import Foundation

final class ImagesListService {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private let urlSession = URLSession.shared
    private var lastTask: URLSessionTask?
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    
    func fetchPhotosNextPage() {
        //assert(Thread.isMainThread)
        lastTask?.cancel()
        
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        lastLoadedPage = (lastLoadedPage ?? 0) + 1
        
        var request = URLRequest.makeRequest(path: "photos?page=\(nextPage)", httpMethod: "GET")
        request.setValue("Bearer \(OAuth2TokenStorage().token!)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<Array<PhotoResult>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let photoResult):
                print("добавили фотку")
                for i in photoResult.indices {
                    let photo = Photo(result: photoResult[i])
                    self.photos.append(photo)
                }
                
                NotificationCenter.default.post (
                    name: ImagesListService.didChangeNotification,
                    object: self)
                
            case .failure(let error):
                print("kakyato hueta proishodit")
                print(error.localizedDescription)
            }
        }
        lastTask = task
        task.resume()
    }
} 
