import CoreData
import Foundation

@objc(DatabaseLink)
public class DatabaseLink: NSManagedObject {

  // MARK: - Properties

  @NSManaged public var id: UUID?
  @NSManaged public var original: String?
  @NSManaged public var shorten: String?
  @NSManaged public var modified: Date?

}

// MARK: - PersistenceEncodableModel

extension DatabaseLink: PersistenceEncodableModel {

  var keyValueRepresentation: KeyValueRepresentation {
    [
      Constant.idPropertyKey: id,
      Constant.originalPropertyKey: original,
      Constant.shortenPropertyKey: shorten,
      Constant.modifiedPropertyKey: modified
    ]
  }

}

// MARK: - Constants

extension DatabaseLink {

  enum Constant {

    static let entityName = "DatabaseLink"

    static let idPropertyKey = #keyPath(DatabaseLink.id)
    static let originalPropertyKey = #keyPath(DatabaseLink.original)
    static let shortenPropertyKey = #keyPath(DatabaseLink.shorten)
    static let modifiedPropertyKey = #keyPath(DatabaseLink.modified)

  }

}
