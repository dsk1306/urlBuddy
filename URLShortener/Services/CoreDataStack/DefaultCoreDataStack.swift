import Combine
import CoreData
import UIKit

final class DefaultCoreDataStack: NSObject {

  // MARK: - Properties

  private let container = NSPersistentCloudKitContainer(name: Constant.containerName)

}

// MARK: - AppLifecycleSubscribable

extension DefaultCoreDataStack: AppLifecycleSubscribableService {

  func handleConnectToScene(with connectionOptions: ConnectionOptions, onError: @escaping ErrorHandler) {
    container.loadPersistentStores { _, error in
      guard let error = error else { return }
      onError(error)
    }
  }

  func handleSceneEnteringBackground(onError: @escaping ErrorHandler) {
    guard viewContext.hasChanges else { return }

    do {
      try viewContext.save()
    } catch {
      onError(error)
    }
  }

}

// MARK: - CoreDataStack

extension DefaultCoreDataStack: CoreDataStack {

  var viewContext: NSManagedObjectContext {
    container.viewContext
  }

  var backgroundContext: NSManagedObjectContext {
    container.newBackgroundContext()
  }

}

// MARK: - Constants

private extension DefaultCoreDataStack {

  enum Constant {

    static let containerName = "URLShortener"

  }

}
