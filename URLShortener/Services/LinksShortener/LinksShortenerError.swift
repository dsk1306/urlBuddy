import Foundation

enum LinksShortenerError: Equatable {

  case decoding
  case badURL
  case badServerResponse
  case invalidURLSubmitted
  case tooManyRequests
  case custom(String)

  // MARK: - Typealiases

  private typealias LocalizedString = URLShortener.LocalizedString.LinksShortenerError

  // MARK: - Initialization

  init(error: Error) {
    if let error = error as? LinksShortenerError {
      self = error
      return
    }

    if let error = error as? URLError {
      switch error.code {
      case .badURL:
        self = .badURL
        return
      case .badServerResponse:
        self = .badServerResponse
        return
      default:
        break
      }
    }

    self = .custom(error.localizedDescription)
  }

}

// MARK: - LinksShortenerError

extension LinksShortenerError: LocalizedError {

  var errorDescription: String? {
    switch self {
    case .decoding:
      return LocalizedString.decoding
    case .badURL, .invalidURLSubmitted:
      return LocalizedString.badURL
    case .badServerResponse:
      return LocalizedString.badServerResponse
    case .tooManyRequests:
      return LocalizedString.tooManyRequests
    case .custom(let string):
      return string
    }
  }

}
