import Foundation

struct Link: Codable, Hashable, Identifiable {

  let id: UUID
  let original: URL
  let shorten: URL

  var originalString: String {
    original.absoluteString.lowercased()
  }

  var shortenString: String {
    shorten.absoluteString.lowercased()
  }

}
