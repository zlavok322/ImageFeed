import Foundation

struct PhotoResult: Codable {
    let urls: UrlsResult
    let id: String
    let height: Int
    let width: Int
    let createdAt: Date?
    let welcomeDescription: String?
    let isLiked: Bool
    
    private enum CodingKeys: String, CodingKey {
        case urls, id, width, height
        case createdAt = "created_at"
        case welcomeDescription = "description"
        case isLiked = "liked_by_user"
    }
}

extension PhotoResult {
    
    struct UrlsResult: Codable {
        let thumbImageURL: String
        let largeImageURL: String
        
        private enum CodingKeys: String, CodingKey {
            case thumbImageURL = "thumb"
            case largeImageURL = "regular"
        }
    }
}
