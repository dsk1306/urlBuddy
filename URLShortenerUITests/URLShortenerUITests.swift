import XCTest

final class URLShortenerUITests: XCTestCase {

	// MARK: - Tests

	func testExample() throws {
		let app = XCUIApplication()
		app.launch()
	}

	func testLaunchPerformance() throws {
		measure(metrics: [XCTApplicationLaunchMetric()]) {
			XCUIApplication().launch()
		}
	}

}
