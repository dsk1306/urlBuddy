import Foundation

enum PersistenceDecodingError: LocalizedError {

  case missingValue(key: String)
  case unexpectedValue(key: String)

}
