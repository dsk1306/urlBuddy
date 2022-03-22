import XCTest

final class URLShortenerUITestsLaunchTests: XCTestCase {

	// MARK: - Tests

	func testLaunch() throws {
		let app = XCUIApplication()
		app.launch()

		let attachment = XCTAttachment(screenshot: app.screenshot())
		attachment.name = "Launch Screen"
		attachment.lifetime = .keepAlways
		add(attachment)
	}

}
