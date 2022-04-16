import XCTest
@testable import URLShortener

final class URLStringValidatorTests: XCTestCase {

  // MARK: - Tests

  func test_isValid1() throws {
    let validator = try URLStringValidator(urlString: "google.com")
    XCTAssertTrue(validator.isValid)
  }

  func test_isValid2() throws {
    let validator = try URLStringValidator(urlString: "yandex.ru")
    XCTAssertTrue(validator.isValid)
  }

  func test_invalid1() throws {
    let validator = try URLStringValidator(urlString: "google.c")
    XCTAssertFalse(validator.isValid)
  }

  func test_invalid2() throws {
    let validator = try URLStringValidator(urlString: "test")
    XCTAssertFalse(validator.isValid)
  }

}
