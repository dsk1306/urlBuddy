import XCTest
@testable import URLShortener

final class LinkTests: XCTestCase {

  // MARK: - Tests

  func test_originalString1() {
    let model = Link.convenienceInit()
    XCTAssertEqual(model.originalString, "example.com")
  }

  func test_originalString2() {
    let model = Link.convenienceInit(
      original: URL(string: "eXample.com")!,
      shorten: URL(string: "eXample22.com")!
    )
    XCTAssertEqual(model.originalString, "example.com")
  }

  func test_originalString3() {
    let model = Link.convenienceInit(
      original: URL(string: "eXample.com/someTesS?sOme=1")!,
      shorten: URL(string: "eXample22.com/someTesS?sOme=1")!
    )
    XCTAssertEqual(model.originalString, "example.com/sometess?some=1")
  }

  func test_shortenString1() {
    let model = Link.convenienceInit()
    XCTAssertEqual(model.shortenString, "example2.com")
  }

  func test_shortenString2() {
    let model = Link.convenienceInit(
      original: URL(string: "eXample22.com")!,
      shorten: URL(string: "eXample.com")!
    )
    XCTAssertEqual(model.shortenString, "example.com")
  }

  func test_shortenString3() {
    let model = Link.convenienceInit(
      original: URL(string: "eXample22.com/someTesS?sOme=1")!,
      shorten: URL(string: "eXample.com/someTesS?sOme=1")!
    )
    XCTAssertEqual(model.shortenString, "example.com/sometess?some=1")
  }

  func test_persistenceEncodableModel() {
    let model = Link.convenienceInit()
    let representation = model.keyValueRepresentation

    XCTAssertEqual(representation[Constant.idKey] as? UUID, Constant.id)
    XCTAssertEqual(representation[Constant.modifiedKey] as? Date, Constant.modified)
    XCTAssertEqual(representation[Constant.originalKey] as? String, Constant.original.absoluteString)
    XCTAssertEqual(representation[Constant.shortenKey] as? String, Constant.shorten.absoluteString)
  }

  func test_persistenceDecodableModel_url() throws {
    let representation: PersistenceDecodableModel.KeyValueRepresentation = [
      Constant.idKey: Constant.id,
      Constant.modifiedKey: Constant.modified,
      Constant.originalKey: Constant.original,
      Constant.shortenKey: Constant.shorten
    ]
    let model = try Link(keyValueRepresentation: representation)

    XCTAssertEqual(model.id, Constant.id)
    XCTAssertEqual(model.shorten, Constant.shorten)
    XCTAssertEqual(model.original, Constant.original)
    XCTAssertEqual(model.modified, Constant.modified)
  }

  func test_persistenceDecodableModel_string() throws {
    let representation: PersistenceDecodableModel.KeyValueRepresentation = [
      Constant.idKey: Constant.id,
      Constant.modifiedKey: Constant.modified,
      Constant.originalKey: Constant.original.absoluteString,
      Constant.shortenKey: Constant.shorten.absoluteString
    ]
    let model = try Link(keyValueRepresentation: representation)

    XCTAssertEqual(model.id, Constant.id)
    XCTAssertEqual(model.shorten, Constant.shorten)
    XCTAssertEqual(model.original, Constant.original)
    XCTAssertEqual(model.modified, Constant.modified)
  }

  func test_persistenceEncodableDecodable() throws {
    let model = Link.convenienceInit()
    let model2 = try Link(keyValueRepresentation: model.keyValueRepresentation)
    XCTAssertEqual(model, model2)
  }

}

// MARK: - Constants

private enum Constant {

  static let id = UUID()
  static let modified = Date()
  static let original = URL(string: "example.com")!
  static let shorten = URL(string: "example2.com")!

  static let idKey = "id"
  static let modifiedKey = "modified"
  static let originalKey = "original"
  static let shortenKey = "shorten"

}

// MARK: - Link Convenience Init

private extension Link {

  static func convenienceInit(original: URL = Constant.original,
                              shorten: URL = Constant.shorten,
                              id: UUID = Constant.id,
                              modified: Date = Constant.modified) -> Link {

    Link(original: original, shorten: shorten, id: id, modified: modified)
  }

}
