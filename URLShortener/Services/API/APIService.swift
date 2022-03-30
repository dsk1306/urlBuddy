import Combine
import Foundation

protocol APIService {

  typealias DataTaskPublisher = AnyPublisher<Data, Error>

  func dataTaskPublisher(forRequestTo path: String, queryItems: [URLQueryItem]?) -> DataTaskPublisher

}

extension APIService {

  func dataTaskPublisher(forRequestTo path: String) -> DataTaskPublisher {
    dataTaskPublisher(forRequestTo: path, queryItems: nil)
  }

}
