import Foundation

final class DefaultServices: Services {

  private(set) lazy var logger: LoggerService = DefaultLoggerService(onOptOut: nil)

  private lazy var coreDataStack: CoreDataStack = DefaultCoreDataStack()

}

// MARK: - AppLifecycleSubscribableService

extension DefaultServices: AppLifecycleSubscribableService {

  func handleConnectToScene(with connectionOptions: ConnectionOptions, onError: @escaping ErrorHandler) {
    coreDataStack.handleConnectToScene(with: connectionOptions, onError: onError)
    logger.handleConnectToScene(with: connectionOptions, onError: onError)
  }

  func handleSceneEnteringBackground(onError: @escaping ErrorHandler) {
    coreDataStack.handleSceneEnteringBackground(onError: onError)
    logger.handleSceneEnteringBackground(onError: onError)
  }

}
