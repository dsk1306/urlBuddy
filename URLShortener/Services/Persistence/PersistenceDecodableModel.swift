import Foundation

protocol PersistenceDecodableModel {

  typealias KeyValueRepresentation = PersistenceEncodableModel.KeyValueRepresentation

  init(keyValueRepresentation: KeyValueRepresentation) throws

}
