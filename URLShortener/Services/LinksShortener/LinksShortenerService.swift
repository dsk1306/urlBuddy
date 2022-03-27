import Combine
import Foundation

protocol LinksShortenerService {

  typealias ShortenLinkPublisher = AnyPublisher<URL, LinksShortenerError>

  func shorten(link: URL) -> ShortenLinkPublisher

}
