import Foundation

enum LinksShortenerError: LocalizedError, Equatable {

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
