import XCTest

final class ScanVaultUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testDocumentListShowsEmptyState() {
        XCTAssertTrue(app.otherElements["document-list"].exists)
        XCTAssertTrue(app.staticTexts["No scans yet"].exists)
    }

    func testAddDocumentFlowIdentifiers() {
        app.buttons["add-document-button"].tap()
        XCTAssertTrue(app.textFields["document-title-field"].exists)
        XCTAssertTrue(app.buttons["choose-photo-button"].exists)
        XCTAssertTrue(app.buttons["camera-button"].exists)
        XCTAssertFalse(app.buttons["save-document-button"].isEnabled)
    }

    func testDetailActionsIdentifiers() {
        app.buttons["document-row-Receipt"].firstMatch.tap()
        XCTAssertTrue(app.otherElements["document-detail-image"].exists)
        XCTAssertTrue(app.otherElements["recognized-text"].exists)
        XCTAssertTrue(app.buttons["share-document-button"].exists)
        XCTAssertTrue(app.buttons["delete-document-button"].exists)
    }
}
