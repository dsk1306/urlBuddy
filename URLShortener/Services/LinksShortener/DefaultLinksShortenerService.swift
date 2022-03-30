import Combine
import Foundation

final class DefaultLinksShortenerService {

  // MARK: - Properties

  private let apiService: APIService

  // MARK: - Initialization

  init(apiService: APIService) {
    self.apiService = apiService
  }

}

// MARK: - Private Methods

private extension DefaultLinksShortenerService {

  static func decodeShortenedURL(from data: Data) throws -> URL {
    do {
      return try JSONDecoder().decode(ResponseModel.self, from: data).result.fullShortLink
    } catch {
      throw LinksShortenerError.decoding
    }
  }

  static func decodeURLShorteningError(from data: Data) throws -> Data {
    if let error = try? JSONDecoder().decode(ResponseErrorModel.self, from: data).apiError {
      throw error
    }
    return data
  }

}

// MARK: - LinksShortenerService

extension DefaultLinksShortenerService: LinksShortenerService {

  func shorten(link: URL) -> ShortenLinkPublisher {
    let queryItem = [
      URLQueryItem(name: "url", value: link.absoluteString)
    ]
    return apiService.dataTaskPublisher(forRequestTo: "shorten", queryItems: queryItem)
      .tryMap(Self.decodeURLShorteningError)
      .tryMap(Self.decodeShortenedURL)
      .mapError { LinksShortenerError(error: $0) }
      .eraseToAnyPublisher()
  }

}
