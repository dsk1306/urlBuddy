import Combine
import CoreData
import Foundation
import Logger

final class DefaultPersistenceService {

  // MARK: - Properties

  private let coreDataStack: CoreDataStack
  private let logger: LoggerService

  private lazy var errorHandler: ErrorHandler = { [weak logger] error in
    logger?.log(error: error)
  }

  // MARK: - Initialization

  init(coreDataStack: CoreDataStack, logger: LoggerService) {
    self.coreDataStack = coreDataStack
    self.logger = logger
  }

}

// MARK: - Private Methods

private extension DefaultPersistenceService {

  static func idPredicate(id: UUID) -> NSPredicate {
    NSPredicate(format: "id == %@", id as CVarArg)
  }

  static func originalPredicate(original: String) -> NSPredicate {
    NSPredicate(format: "original == %@", original as CVarArg)
  }

  static func link(from object: NSManagedObject, onEncodingError: ErrorHandler?) -> Link? {
    guard let encodable = object as? PersistenceEncodableModel else { return nil }
    do {
      return try Link(keyValueRepresentation: encodable.keyValueRepresentation)
    } catch {
      onEncodingError?(error)
      return nil
    }
  }

}

// MARK: - Private Methods - Save

private extension DefaultPersistenceService {

  func save(model: PersistenceEncodableModel,
            forEntityName entityName: String,
            context: NSManagedObjectContext) -> SavePublisher {

    Future<Void, Error> { promise in
      context.perform {
        do {
          let entity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)

          model.keyValueRepresentation
            .compactMapValues { $0 }
            .forEach { entity.setValue($0.value, forKey: $0.key) }

          try context.save()

          promise(.success(()))
        } catch {
          promise(.failure(error))
        }
      }
    }
    .eraseToAnyPublisher()
  }

  func save(model: PersistenceEncodableModel,
            forEntityName entityName: String,
            context: NSManagedObjectContext) async throws {

    try await context.perform {
      let entity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)

      model.keyValueRepresentation
        .compactMapValues { $0 }
        .forEach { entity.setValue($0.value, forKey: $0.key) }

      try context.save()
    }
  }

}

// MARK: - Private Methods - Fetch

private extension DefaultPersistenceService {

  func fetch(withEntityName entityName: String,
             context: NSManagedObjectContext,
             sortDescriptors: [NSSortDescriptor]? = nil,
             predicate: NSPredicate? = nil) -> FetchPublisher<[NSManagedObject]> {

    Future { promise in
      context.perform {
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.sortDescriptors = sortDescriptors
        request.predicate = predicate

        do {
          let records = try context.fetch(request)
          promise(.success(records))
        } catch {
          promise(.failure(error))
        }
      }
    }
    .eraseToAnyPublisher()
  }

  func fetch(withEntityName entityName: String,
             context: NSManagedObjectContext,
             sortDescriptors: [NSSortDescriptor]? = nil,
             predicate: NSPredicate? = nil) async throws -> [NSManagedObject] {

    try await context.perform {
      let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
      request.sortDescriptors = sortDescriptors
      request.predicate = predicate

      return try context.fetch(request)
    }
  }

}

// MARK: - Private Methods - Edit

private extension DefaultPersistenceService {

  func edit<Object>(object: Object,
                    withEntityName entityName: String,
                    context: NSManagedObjectContext) -> EditPublisher where Object: PersistenceEncodableModel & Identifiable {

    guard let objectID = object.id as? UUID else {
      return Fail(error: ServiceError.unexpectedEditedObjectID).eraseToAnyPublisher()
    }

    return fetch(
      withEntityName: entityName,
      context: context,
      predicate: Self.idPredicate(id: objectID)
    )
    .tryMap { records -> NSManagedObject in
      if records.count > 1 {
        throw ServiceError.unexpectedEditedRecordsAmount
      }
      guard let record = records.first else {
        throw ServiceError.nilEditRecord
      }

      object.keyValueRepresentation.forEach { representation in
        record.setValue(representation.value, forKey: representation.key)
      }
      return record
    }
    .flatMap { _ -> Future<Void, Error> in
      Future { promise in
        context.perform {
          do {
            try context.save()

            promise(.success(()))
          } catch {
            promise(.failure(error))
          }
        }
      }
    }
    .eraseToAnyPublisher()
  }

  func edit<Object>(object: Object,
                    withEntityName entityName: String,
                    context: NSManagedObjectContext) async throws where Object: PersistenceEncodableModel & Identifiable {

    guard let objectID = object.id as? UUID else {
      throw ServiceError.unexpectedEditedObjectID
    }

    let records = try await fetch(
      withEntityName: entityName,
      context: context,
      predicate: Self.idPredicate(id: objectID)
    )

    if records.count > 1 {
      throw ServiceError.unexpectedEditedRecordsAmount
    }
    guard let record = records.first else {
      throw ServiceError.nilEditRecord
    }

    object.keyValueRepresentation.forEach { representation in
      record.setValue(representation.value, forKey: representation.key)
    }

    try await context.perform {
      try context.save()
    }
  }

}

// MARK: - Private Methods - Delete

private extension DefaultPersistenceService {

  func delete<Object>(object: Object,
                      withEntityName entityName: String,
                      context: NSManagedObjectContext) -> DeletePublisher
                      where Object: PersistenceEncodableModel & Identifiable {

    guard let objectID = object.id as? UUID else {
      return Fail(error: ServiceError.unexpectedDeletedObjectID).eraseToAnyPublisher()
    }

    return fetch(
      withEntityName: entityName,
      context: context,
      predicate: Self.idPredicate(id: objectID)
    )
    .tryMap { records -> NSManagedObject in
      if records.count > 1 {
        throw ServiceError.unexpectedDeletedRecordsAmount
      }
      guard let record = records.first else {
        throw ServiceError.nilDeleteRecord
      }
      return record
    }
    .flatMap { record -> Future<Void, Error> in
      Future { promise in
        context.perform {
          do {
            context.delete(record)
            try context.save()
            promise(.success(()))
          } catch {
            promise(.failure(error))
          }
        }
      }
    }
    .eraseToAnyPublisher()
  }

  func delete<Object>(object: Object,
                      withEntityName entityName: String,
                      context: NSManagedObjectContext) async throws
                      where Object: PersistenceEncodableModel & Identifiable {

    guard let objectID = object.id as? UUID else {
      throw ServiceError.unexpectedDeletedObjectID
    }

    let records = try await fetch(
      withEntityName: entityName,
      context: context,
      predicate: Self.idPredicate(id: objectID)
    )

    if records.count > 1 {
      throw ServiceError.unexpectedDeletedRecordsAmount
    }
    guard let record = records.first else {
      throw ServiceError.nilDeleteRecord
    }

    try await context.perform {
      context.delete(record)
      try context.save()
    }
  }

}

// MARK: - PersistenceService

extension DefaultPersistenceService: PersistenceService {

  func save(link: Link) -> SavePublisher {
    save(model: link, forEntityName: Constant.linkEntityName, context: coreDataStack.backgroundContext)
  }

  func save(link: Link) async throws {
    try await save(model: link, forEntityName: Constant.linkEntityName, context: coreDataStack.backgroundContext)
  }

  func edit(link: Link) -> EditPublisher {
    edit(object: link, withEntityName: Constant.linkEntityName, context: coreDataStack.backgroundContext)
  }

  func edit(link: Link) async throws {
    try await edit(object: link, withEntityName: Constant.linkEntityName, context: coreDataStack.backgroundContext)
  }

  func delete(link: Link) -> DeletePublisher {
    delete(object: link, withEntityName: Constant.linkEntityName, context: coreDataStack.backgroundContext)
  }

  func delete(link: Link) async throws {
    try await delete(object: link, withEntityName: Constant.linkEntityName, context: coreDataStack.backgroundContext)
  }

  func fetchLinks() -> FetchPublisher<[Link]> {
    fetch(
      withEntityName: Constant.linkEntityName,
      context: coreDataStack.viewContext,
      sortDescriptors: [Constant.modifiedSortDescriptor]
    )
    .map { [weak self] objects in
      objects.compactMap { object in
        Self.link(from: object, onEncodingError: self?.errorHandler)
      }
    }
    .eraseToAnyPublisher()
  }

  func fetchLinks() async throws -> [Link] {
    try await fetch(
      withEntityName: Constant.linkEntityName,
      context: coreDataStack.viewContext,
      sortDescriptors: [Constant.modifiedSortDescriptor]
    )
    .compactMap { object in
      Self.link(from: object, onEncodingError: errorHandler)
    }
  }

  func fetchLinks(withOriginalURL original: String) -> FetchPublisher<[Link]> {
    fetch(
      withEntityName: Constant.linkEntityName,
      context: coreDataStack.viewContext,
      sortDescriptors: [Constant.modifiedSortDescriptor],
      predicate: Self.originalPredicate(original: original)
    )
    .map { [weak self] objects in
      objects.compactMap { object in
        Self.link(from: object, onEncodingError: self?.errorHandler)
      }
    }
    .eraseToAnyPublisher()
  }

  func fetchLinks(withOriginalURL original: String) async throws -> [Link] {
    try await fetch(
      withEntityName: Constant.linkEntityName,
      context: coreDataStack.viewContext,
      sortDescriptors: [Constant.modifiedSortDescriptor],
      predicate: Self.originalPredicate(original: original)
    )
    .compactMap { object in
      Self.link(from: object, onEncodingError: errorHandler)
    }
  }

}

// MARK: - Constants

private extension DefaultPersistenceService {

  enum Constant {

    static let linkEntityName = DatabaseLink.Constant.entityName

    static let modifiedSortDescriptor = NSSortDescriptor(
      key: DatabaseLink.Constant.modifiedPropertyKey,
      ascending: false
    )

  }

}

// MARK: - Service Error

private extension DefaultPersistenceService {

  enum ServiceError: LocalizedError {

    case unexpectedDeletedObjectID
    case unexpectedEditedObjectID
    case unexpectedDeletedRecordsAmount
    case unexpectedEditedRecordsAmount
    case nilDeleteRecord
    case nilEditRecord

  }

}
