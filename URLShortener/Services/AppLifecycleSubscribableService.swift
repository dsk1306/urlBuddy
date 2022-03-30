import UIKit

protocol AppLifecycleSubscribableService {

  typealias ErrorHandler = (Error) -> Void
  typealias ConnectionOptions = UIScene.ConnectionOptions

  func handleSceneEnteringBackground(onError: @escaping ErrorHandler)
  func handleConnectToScene(with connectionOptions: ConnectionOptions, onError: @escaping ErrorHandler)

}

extension AppLifecycleSubscribableService {

  func handleSceneEnteringBackground(onError: @escaping ErrorHandler) {}
  func handleConnectToScene(with connectionOptions: ConnectionOptions, onError: @escaping ErrorHandler) {}

}
