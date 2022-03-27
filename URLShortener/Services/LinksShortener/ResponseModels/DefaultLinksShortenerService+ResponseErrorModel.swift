import Foundation

extension DefaultLinksShortenerService {

  struct ResponseErrorModel: Decodable {

    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
      case error
      case errorCode = "error_code"
    }

    // MARK: - Properties

    let errorCode: Int
    let error: String

    var apiError: LinksShortenerError? {
      switch errorCode {
      case 2:
        return .invalidURLSubmitted
      case 3:
        return .tooManyRequests
      default:
        return .custom(error)
      }
    }

    // MARK: - Initialization

    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.errorCode = try container.decode(Int.self, forKey: .errorCode)
      self.error = try container.decode(String.self, forKey: .error)
    }

  }

}
