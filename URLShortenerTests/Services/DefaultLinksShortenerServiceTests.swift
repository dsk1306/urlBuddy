import Combine
import XCTest
@testable import URLShortener

final class DefaultLinksShortenerServiceTests: XCTestCase {

  // MARK: - Properties

  private var shortenURL: URL?
  private var shorteningError: LinksShortenerError?
  private var shorteningFinished = false
  private var cancellable: AnyCancellable?

  private let apiService = MockAPIService()

  private lazy var service = DefaultLinksShortenerService(apiService: apiService)

  // MARK: - Base Class

  override func setUp() {
    super.setUp()

    shortenURL = nil
    shorteningError = nil
    shorteningFinished = false
    cancellable = nil
  }

  // MARK: - Tests

  func test_success() {
    apiService.mode = .success

    let expectationName = "\(Self.self)_\(#function)_"
    let valueExpectation = expectation(description: expectationName + "valueExpectation")
    let completionExpectation = expectation(description: expectationName + "completionExpectation")

    cancellable = service.shorten(link: Constant.linkToShorten)
      .sink(
        receiveCompletion: { [weak self] in
          self?.handle(completion: $0)
          completionExpectation.fulfill()
        },
        receiveValue: { [weak self] in
          self?.shortenURL = $0
          valueExpectation.fulfill()
        }
      )

    wait(for: [valueExpectation, completionExpectation], timeout: Constant.timeout)

    XCTAssertEqual(shortenURL, Constant.shortenURL)
    XCTAssertNil(shorteningError)
    XCTAssertTrue(shorteningFinished)
  }

  func test_invalidURLSubmitted() {
    apiService.mode = .invalidURLSubmitted

    let expectationName = "\(Self.self)_\(#function)_"
    let valueExpectation = expectation(description: expectationName + "valueExpectation")
    valueExpectation.isInverted = true
    let completionExpectation = expectation(description: expectationName + "completionExpectation")

    cancellable = service.shorten(link: Constant.linkToShorten)
      .sink(
        receiveCompletion: { [weak self] in
          self?.handle(completion: $0)
          completionExpectation.fulfill()
        },
        receiveValue: { [weak self] in
          self?.shortenURL = $0
          valueExpectation.fulfill()
        }
      )

    wait(for: [valueExpectation, completionExpectation], timeout: Constant.timeout)

    XCTAssertNil(shortenURL)
    XCTAssertEqual(shorteningError, .invalidURLSubmitted)
    XCTAssertFalse(shorteningFinished)
  }

  func test_badServerResponse() {
    apiService.mode = .badServerResponse

    let expectationName = "\(Self.self)_\(#function)_"
    let valueExpectation = expectation(description: expectationName + "valueExpectation")
    valueExpectation.isInverted = true
    let completionExpectation = expectation(description: expectationName + "completionExpectation")

    cancellable = service.shorten(link: Constant.linkToShorten)
      .sink(
        receiveCompletion: { [weak self] in
          self?.handle(completion: $0)
          completionExpectation.fulfill()
        },
        receiveValue: { [weak self] in
          self?.shortenURL = $0
          valueExpectation.fulfill()
        }
      )

    wait(for: [valueExpectation, completionExpectation], timeout: Constant.timeout)

    XCTAssertNil(shortenURL)
    XCTAssertEqual(shorteningError, .decoding)
    XCTAssertFalse(shorteningFinished)
  }

  func test_badServerResponse2() {
    apiService.mode = .badServerResponse2

    let expectationName = "\(Self.self)_\(#function)_"
    let valueExpectation = expectation(description: expectationName + "valueExpectation")
    valueExpectation.isInverted = true
    let completionExpectation = expectation(description: expectationName + "completionExpectation")

    cancellable = service.shorten(link: Constant.linkToShorten)
      .sink(
        receiveCompletion: { [weak self] in
          self?.handle(completion: $0)
          completionExpectation.fulfill()
        },
        receiveValue: { [weak self] in
          self?.shortenURL = $0
          valueExpectation.fulfill()
        }
      )

    wait(for: [valueExpectation, completionExpectation], timeout: Constant.timeout)

    XCTAssertNil(shortenURL)
    XCTAssertEqual(shorteningError, .decoding)
    XCTAssertFalse(shorteningFinished)
  }

}

// MARK: - Private Methods

private extension DefaultLinksShortenerServiceTests {

  func handle(completion: Subscribers.Completion<LinksShortenerError>) {
    switch completion {
    case .failure(let error):
      shorteningError = error
    case .finished:
      shorteningFinished = true
    }
  }

}

// MARK: - Constants

private extension DefaultLinksShortenerServiceTests {

  enum Constant {

    static let linkToShorten = URL(string: "example.com")!
    static let shortenURL = URL(string: "https://shrtco.de/R36Ulk")!

    static let timeout: TimeInterval = 2

  }

}

// MARK: - MockAPIService

private extension DefaultLinksShortenerServiceTests {

  final class MockAPIService: APIService {

    // swiftlint:disable:next nesting
    enum Mode {

      case success
      case invalidURLSubmitted
      case badServerResponse
      case badServerResponse2

      func data() throws -> Data {
        switch self {
        case .success:
          return try MockJSONLoader.loadJSON(MockJSON.URLShortenerTests.success)
        case .invalidURLSubmitted:
          return try MockJSONLoader.loadJSON(MockJSON.URLShortenerTests.invalidURLSubmitted)
        case .badServerResponse:
          return Data()
        case .badServerResponse2:
          return try MockJSONLoader.loadJSON(MockJSON.URLShortenerTests.badServerResponse)
        }
      }

    }

    var mode = Mode.success

    func dataTaskPublisher(forRequestTo path: String, queryItems: [URLQueryItem]?) -> DataTaskPublisher {
      do {
        return Just(try mode.data())
          .setFailureType(to: Error.self)
          .eraseToAnyPublisher()
      } catch {
        return Fail(error: error)
          .eraseToAnyPublisher()
      }
    }

  }

}
