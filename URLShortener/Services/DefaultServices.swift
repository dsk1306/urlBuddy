import Foundation

final class DefaultServices: Services {

  private(set) lazy var logger: LoggerService = DefaultLoggerService(onOptOut: nil)
  private(set) lazy var clipboard: ClipboardService = DefaultClipboardService()

  private(set) lazy var persistence: PersistenceService = DefaultPersistenceService(
    coreDataStack: coreDataStack,
    logger: logger
  )

  private(set) lazy var linksShortener: LinksShortenerService = DefaultLinksShortenerService(
    apiService: api
  )

  private lazy var coreDataStack: CoreDataStack = DefaultCoreDataStack()
  private lazy var api: APIService = DefaultAPIService(baseURL: Constant.baseURL)

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

// MARK: - Constants

private extension DefaultServices {

  enum Constant {

    static let baseURL = "https://api.shrtco.de/v2/"

  }

}
