import XCTest
@testable import URLShortener

final class LinksHistoryItemCellModelTests: XCTestCase {

  // MARK: - Tests

  func test_init() {
    let link = Link(
      original: .init(string: Constant.link1)!,
      shorten: .init(string: Constant.link2)!
    )
    let model = LinksHistory.ItemCell.Model(link: link)

    XCTAssertEqual(model.originalURL, Constant.link1)
    XCTAssertEqual(model.shortenURL, Constant.link2)
  }

  func test_init2() {
    let link = Link(
      original: .init(string: Constant.link1.uppercased())!,
      shorten: .init(string: Constant.link2.uppercased())!
    )
    let model = LinksHistory.ItemCell.Model(link: link)

    XCTAssertEqual(model.originalURL, Constant.link1)
    XCTAssertEqual(model.shortenURL, Constant.link2)
  }

}

// MARK: - Constants

private extension LinksHistoryItemCellModelTests {

  enum Constant {

    static let link1 = "test1.com"
    static let link2 = "test2.com"

  }

}
