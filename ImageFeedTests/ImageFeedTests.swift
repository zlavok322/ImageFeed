@testable import ImageFeed
import XCTest

final class ImageFeedTests: XCTestCase {
    func testFetchPhoto()  {
        let service = ImagesListService()
        
        let expectation = expectation(description: "Wait for Notification")
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { _ in
                expectation.fulfill()
            }
        
        service.fetchPhotosNextPage()
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(service.photos.count, 10)
    }
}
