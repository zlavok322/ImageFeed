
import XCTest

final class ImageFeedUITests: XCTestCase {

    private let app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch() // запускаем приложение перед каждый тестом
    }
    
    func testAuth() throws {
        sleep(5)
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 8))
        
        // login
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText("email)
        webView.swipeUp()
        
        // password
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        passwordTextField.typeText("password")
        webView.swipeUp()
        
        sleep(2)
        
        webView.buttons["Login"].tap()
        
        // table
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        
        print(app.debugDescription)
    }
    
    func testFeed() throws {
        sleep(5)
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        sleep(2)
        cell.swipeUp()
        
        sleep(2)
       
        // like
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        cellToLike.buttons["like"].tap()
        sleep(5)
        cellToLike.buttons["like"].tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        let image = app.scrollViews.element(boundBy: 0)
        //zoom in
        image.pinch(withScale: 3, velocity: 1)
        // zoom out
        sleep(5)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let backButton = app.buttons["backButton"]
        sleep(5)
        backButton.tap()
        
    }
    
    func testProfile() throws {
        sleep(5)
        // open profile
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        sleep(3)
        
        // check labels
        XCTAssertTrue(app.staticTexts["Vyacheslav Shestakov"].exists)
        sleep(2)
        XCTAssertTrue(app.staticTexts["@zlavok322"].exists)
        sleep(2)
        let logoutButton = app.buttons["logoutButton"]
        sleep(5)
        logoutButton.tap()
        
        sleep(3)
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
    
    
}
