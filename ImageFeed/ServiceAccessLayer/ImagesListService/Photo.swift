import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
    
    init(result: PhotoResult) {
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        self.createdAt = result.createdAt
        self.welcomeDescription = result.welcomeDescription
        self.thumbImageURL = result.urls.thumbImageURL
        self.largeImageURL = result.urls.largeImageURL
        self.isLiked = result.isLiked
    }
}
