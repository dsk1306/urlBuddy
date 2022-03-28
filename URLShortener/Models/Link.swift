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
    guard let original = keyValueRepresentation[PropertyKey.original] as? String else {
      throw PersistenceDecodingError.missingValue(key: PropertyKey.original)
    }
    guard let originalURL = URL(string: original) else {
      throw PersistenceDecodingError.unexpectedValue(key: PropertyKey.original)
    }
    guard let shorten = keyValueRepresentation[PropertyKey.shorten] as? String else {
      throw PersistenceDecodingError.missingValue(key: PropertyKey.shorten)
    }
    guard let shortenURL = URL(string: shorten) else {
      throw PersistenceDecodingError.unexpectedValue(key: PropertyKey.shorten)
    }
    guard let modified = keyValueRepresentation[PropertyKey.modified] as? Date else {
      throw PersistenceDecodingError.missingValue(key: PropertyKey.modified)
    }

    self.id = id
    self.original = originalURL
    self.shorten = shortenURL
    self.modified = modified
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
