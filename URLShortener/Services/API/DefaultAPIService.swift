import Combine
import Foundation

final class DefaultAPIService {

  // MARK: - Typealiases

  fileprivate typealias Output = URLSession.DataTaskPublisher.Output

  // MARK: - Properties

  private let baseURL: String

  private lazy var requestQueue = DispatchQueue(label: "APIReqiestQueue" + baseURL, qos: .userInteractive)

  // MARK: - Initialization

  init(baseURL: String) {
    self.baseURL = baseURL
  }

}

// MARK: - Private Methods

private extension DefaultAPIService {

  static func validate(output: Output) throws -> Output {
    guard let statusCode = (output.response as? HTTPURLResponse)?.statusCode else {
      throw URLError(.badServerResponse)
    }
    switch statusCode {
    case 200 ..< 500:
      return output
    default:
      throw URLError(.badServerResponse)
    }
  }

}

// MARK: - APIService

extension DefaultAPIService: APIService {

  func dataTaskPublisher(forRequestTo path: String, queryItems: [URLQueryItem]?) -> DataTaskPublisher {
    guard
      let baseURL = URL(string: baseURL)?.appendingPathComponent(path),
      var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
    else {
      return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
    }

    components.queryItems = queryItems

    guard let requestURL = components.url else {
      return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
    }

    let request = URLRequest(url: requestURL)

    return URLSession.shared.dataTaskPublisher(for: request)
      .subscribe(on: requestQueue)
      .tryMap { try Self.validate(output: $0) }
      .map { $0.data }
      .eraseToAnyPublisher()
  }

}
