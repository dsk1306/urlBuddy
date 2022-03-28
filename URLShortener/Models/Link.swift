import Foundation

struct Link: Codable, Hashable, Identifiable {

  let id: UUID
  let original: URL
  let shorten: URL
  let modified: Date

  var originalString: String {
    original.absoluteString.lowercased()
  }

  var shortenString: String {
    shorten.absoluteString.lowercased()
  }

}

// MARK: - PersistenceEncodableModel

extension Link: PersistenceEncodableModel {

  var keyValueRepresentation: KeyValueRepresentation {
    [
      PropertyKey.id: id,
      PropertyKey.original: originalString,
      PropertyKey.shorten: shortenString,
      PropertyKey.modified: modified
    ]
  }

}

// MARK: - PersistenceDecodableModel

extension Link: PersistenceDecodableModel {

  init(keyValueRepresentation: KeyValueRepresentation) throws {
    guard let id = keyValueRepresentation[PropertyKey.id] as? UUID else {
      throw PersistenceDecodingError.missingValue(key: PropertyKey.id)
    }
    guard let modified = keyValueRepresentation[PropertyKey.modified] as? Date else {
      throw PersistenceDecodingError.missingValue(key: PropertyKey.modified)
    }

    self.id = id
    self.modified = modified
    self.original = try Self.url(for: PropertyKey.original, from: keyValueRepresentation)
    self.shorten = try Self.url(for: PropertyKey.shorten, from: keyValueRepresentation)
  }

  private static func url(for key: String, from keyValueRepresentation: KeyValueRepresentation) throws -> URL {
    guard let value = keyValueRepresentation[key] else {
      throw PersistenceDecodingError.missingValue(key: key)
    }
    if let url = value as? URL {
      return url
    } else if let urlString = value as? String, let url = URL(string: urlString) {
      return url
    } else {
      throw PersistenceDecodingError.unexpectedValue(key: key)
    }
  }

}

// MARK: - Constants

private extension Link {

  enum PropertyKey {

    private typealias Constant = DatabaseLink.Constant

    static let id = Constant.idPropertyKey
    static let original = Constant.originalPropertyKey
    static let shorten = Constant.shortenPropertyKey
    static let modified = Constant.modifiedPropertyKey

  }

}
