import CoreData
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

	// MARK: - Typealiases

	typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]?

	// MARK: - Properties

	lazy var persistentContainer: NSPersistentCloudKitContainer = {
		let container = NSPersistentCloudKitContainer(name: "URLShortener")
		container.loadPersistentStores { _, error in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		}
		return container
	}()

	// MARK: - Public Methods

	func saveContext() {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}

	// MARK: - UIApplicationDelegate

	func application(_ application: UIApplication,
									 didFinishLaunchingWithOptions launchOptions: LaunchOptions) -> Bool {

		true
	}

	func application(_ application: UIApplication,
									 configurationForConnecting connectingSceneSession: UISceneSession,
									 options: UIScene.ConnectionOptions) -> UISceneConfiguration {

		UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

}
