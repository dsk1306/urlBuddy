import Foundation

enum LinksShortenerError: LocalizedError {

  case decoding
  case badURL
  case badServerResponse
  case invalidURLSubmitted
  case tooManyRequests
  case custom(String)

  // MARK: - Initialization

  init(error: Error) {
    if let error = error as? LinksShortenerError {
      self = error
    }

    if let error = error as? URLError {
      switch error.code {
      case .badURL:
        self = .badURL
      case .badServerResponse:
        self = .badServerResponse
      default:
        break
      }
    }

    self = .custom(error.localizedDescription)
  }

}
