import Combine
import Foundation

protocol PersistenceService {

  typealias SavePublisher = AnyPublisher<Void, Error>
  typealias EditPublisher = AnyPublisher<Void, Error>
  typealias DeletePublisher = AnyPublisher<Void, Error>
  typealias FetchPublisher<Output> = AnyPublisher<Output, Error>
  typealias ErrorHandler = (Error) -> Void

  func save(link: Link) -> SavePublisher
  func save(link: Link) async throws

  func delete(link: Link) -> DeletePublisher
  func delete(link: Link) async throws

  func fetchLinks(onError: @escaping ErrorHandler) -> FetchPublisher<[Link]>

}
