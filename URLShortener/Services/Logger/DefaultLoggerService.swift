import Foundation
import Logger

// MARK: - AppLifecycleSubscribableService

extension DefaultLoggerService: AppLifecycleSubscribableService {

  func handleConnectToScene(with connectionOptions: ConnectionOptions,
                            onError: @escaping ErrorHandler) {

    let releaseStage: LoggerReleaseStage
    #if DEBUG
    releaseStage = .development
    #else
    configuration.releaseStage = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
      ? releaseStage = .testFlight
      : releaseStage = .production
    #endif

    start(releaseStage: releaseStage, apiKey: Constant.apiKey)
  }

}

// MARK: - Constants

private extension DefaultLoggerService {

  enum Constant {

    static let apiKey = "e24bffe1629ee22a401c574d29a98d2f"

  }

}
