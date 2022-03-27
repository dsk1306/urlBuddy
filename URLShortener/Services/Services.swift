import Foundation

final class Services {

  private lazy var coreDataStack: CoreDataStack = DefaultCoreDataStack()

}

// MARK: - AppLifecycleSubscribableService

extension Services: AppLifecycleSubscribableService {

  func handleConnectToScene(with connectionOptions: ConnectionOptions, onError: @escaping ErrorHandler) {
    coreDataStack.handleConnectToScene(with: connectionOptions, onError: onError)
  }

  func handleSceneEnteringBackground(onError: @escaping ErrorHandler) {
    coreDataStack.handleSceneEnteringBackground(onError: onError)
  }

}
