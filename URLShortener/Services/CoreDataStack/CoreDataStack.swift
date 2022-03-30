import CoreData
import Foundation

protocol CoreDataStack: AnyObject, AppLifecycleSubscribableService {

  /// The managed object context associated with the main queue.
  var viewContext: NSManagedObjectContext { get }

  /// A newly created private managed object context.
  var backgroundContext: NSManagedObjectContext { get }

}
