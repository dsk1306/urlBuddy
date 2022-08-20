import Foundation

enum MockJSON {}

// MARK: - URLShortenerTests

extension MockJSON {

  enum URLShortenerTests: MockJSONType {

    case invalidURLSubmitted
    case badServerResponse
    case success

    var fileName: String {
      switch self {
      case .invalidURLSubmitted:
        return "URLShortenerTests_InvalidURLSubmitted"
      case .success:
        return "URLShortenerTests_Success"
      case .badServerResponse:
        return "URLShortenerTests_BadServerResponse"
      }
    }

  }

}
