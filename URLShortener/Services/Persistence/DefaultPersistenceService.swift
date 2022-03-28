import Combine
import CoreData
import Foundation

final class DefaultPersistenceService {

  // MARK: - Properties

  private let coreDataStack: CoreDataStack

  // MARK: - Initialization

  init(coreDataStack: CoreDataStack) {
    self.coreDataStack = coreDataStack
  }

}

// MARK: - Private Methods

private extension DefaultPersistenceService {

  func save(model: PersistenceEncodableModel,
            forEntityName entityName: String,
            context: NSManagedObjectContext) -> SaveResult {

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

  func fetch(withEntityName entityName: String,
             context: NSManagedObjectContext,
             sortDescriptors: [NSSortDescriptor]? = nil,
             predicate: NSPredicate? = nil) -> FetchResult<[NSManagedObject]> {

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

  func delete<Object>(object: Object,
                      withEntityName entityName: String,
                      context: NSManagedObjectContext) -> DeleteResult
                      where Object: PersistenceEncodableModel & Identifiable {

    guard let objectID = object.id as? UUID else {
      return Fail(error: ServiceError.unexpectedDeletedObjectID).eraseToAnyPublisher()
    }

    return fetch(
      withEntityName: entityName,
      context: context,
      predicate: NSPredicate(format: "id == %@", objectID as CVarArg)
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

  func edit<Object>(object: Object,
                    withEntityName entityName: String,
                    context: NSManagedObjectContext) -> EditResult
                    where Object: PersistenceEncodableModel & Identifiable {

    guard let objectID = object.id as? UUID else {
      return Fail(error: ServiceError.unexpectedEditedObjectID).eraseToAnyPublisher()
    }

    return fetch(
      withEntityName: entityName,
      context: context,
      predicate: NSPredicate(format: "id == %@", objectID as CVarArg)
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

}

// MARK: - PersistenceService

extension DefaultPersistenceService: PersistenceService {

  func save(link: Link) -> SaveResult {
    save(model: link, forEntityName: Constant.linkEntityName, context: coreDataStack.backgroundContext)
  }

  func delete(link: Link) -> DeleteResult {
    delete(object: link, withEntityName: Constant.linkEntityName, context: coreDataStack.backgroundContext)
  }

  func fetchLinks(onError: @escaping ErrorHandler) -> FetchResult<[Link]> {
    fetch(
      withEntityName: Constant.linkEntityName,
      context: coreDataStack.viewContext,
      sortDescriptors: [
        .init(key: DatabaseLink.Constant.modifiedPropertyKey, ascending: true)
      ]
    )
    .map { objects in
      objects.compactMap { object in
        guard let encodable = object as? PersistenceEncodableModel else { return nil }
        do {
          return try Link(keyValueRepresentation: encodable.keyValueRepresentation)
        } catch {
          onError(error)
          return nil
        }
      }
    }
    .eraseToAnyPublisher()
  }

}

// MARK: - Constants

private extension DefaultPersistenceService {

  enum Constant {

    static let linkEntityName = DatabaseLink.Constant.entityName

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
