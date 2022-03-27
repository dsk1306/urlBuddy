import Foundation

extension DefaultLinksShortenerService.ResponseModel {

  struct Result: Decodable {

    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
      case fullShortLink = "full_short_link"
    }

    // MARK: - Properties

    let fullShortLink: URL

    // MARK: - Decodable

    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      let fullShortLinkString = try container.decode(String.self, forKey: .fullShortLink)
      guard let fullShortLink = URL(string: fullShortLinkString) else {
        let context = DecodingError.Context(
          codingPath: [CodingKeys.fullShortLink],
          debugDescription: "",
          underlyingError: nil
        )
        throw DecodingError.dataCorrupted(context)
      }
      self.fullShortLink = fullShortLink
    }

  }

}
