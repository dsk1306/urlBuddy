import Combine
import Foundation

protocol PersistenceService {

  typealias SaveResult = AnyPublisher<Void, Error>
  typealias EditResult = AnyPublisher<Void, Error>
  typealias DeleteResult = AnyPublisher<Void, Error>
  typealias FetchResult<Output> = AnyPublisher<Output, Error>
  typealias ErrorHandler = (Error) -> Void

  func save(link: Link) -> SaveResult
  func delete(link: Link) -> DeleteResult
  func fetchLinks(onError: @escaping ErrorHandler) -> FetchResult<[Link]>

}
