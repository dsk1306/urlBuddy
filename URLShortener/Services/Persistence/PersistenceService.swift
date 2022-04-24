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

  func edit(link: Link) -> EditPublisher
  func edit(link: Link) async throws

  func fetchLinks() -> FetchPublisher<[Link]>
  func fetchLinks() async throws -> [Link]

  func fetchLinks(withOriginalURL original: String) -> FetchPublisher<[Link]>
  func fetchLinks(withOriginalURL original: String) async throws -> [Link]

}
