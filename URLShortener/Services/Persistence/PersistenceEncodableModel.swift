import Foundation

protocol PersistenceEncodableModel {

  typealias KeyValueRepresentation = [String: Any?]

  var keyValueRepresentation: KeyValueRepresentation { get }

}
