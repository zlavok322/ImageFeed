import Foundation

public final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private let urlSession = URLSession.shared
    private var lastTask: URLSessionTask?
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        lastTask?.cancel()
        
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        lastLoadedPage = nextPage
        
        var request = URLRequest.makeRequest(path: "photos?page=\(nextPage)", httpMethod: "GET")
        request.setValue("Bearer \(OAuth2TokenStorage().token!)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<Array<PhotoResult>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let photoResult):
                for i in photoResult.indices {
                    let createdAt = photoResult[i].createdAt
                    let dateFormatter = ISO8601DateFormatter()
                    let date = dateFormatter.date(from: createdAt)
                    self.photos.append(
                        Photo(
                            id: photoResult[i].id,
                            size: CGSize(width: photoResult[i].width, height: photoResult[i].height),
                            createdAt: date,
                            welcomeDescription: photoResult[i].welcomeDescription,
                            thumbImageURL: photoResult[i].urls.thumbImageURL,
                            largeImageURL: photoResult[i].urls.largeImageURL,
                            isLiked: photoResult[i].isLiked))
                }
                
                NotificationCenter.default.post (
                    name: ImagesListService.didChangeNotification,
                    object: self)
                
            case .failure(let error):
                print(error.localizedDescription)
                self.lastTask = nil
            }
        }
        lastTask = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<NoReply, Error>) -> Void) {
        assert(Thread.isMainThread)
        lastTask?.cancel()
        
        var request: URLRequest
        
        if isLike {
            request = URLRequest.makeRequest(path: "photos/\(photoId)/like", httpMethod: "POST")
            request.setValue("Bearer \(OAuth2TokenStorage().token!)", forHTTPHeaderField: "Authorization")
        } else {
            request = URLRequest.makeRequest(path: "photos/\(photoId)/like", httpMethod: "DELETE")
            request.setValue("Bearer \(OAuth2TokenStorage().token!)", forHTTPHeaderField: "Authorization")
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<NoReply, Error>) in
            guard let self else { return }
            switch result {
            case .success(_):
                // Поиск индекса элемента
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    // Текущий элемент
                   let photo = self.photos[index]
                   // Копия элемента с инвертированным значением isLiked.
                   let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked
                        )
                    // Заменяем элемент в массиве.
                    DispatchQueue.main.async {
                        self.photos[index] = newPhoto
                        completion(result)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(result)
            }
        }
        lastTask = task
        task.resume()
    }
}
