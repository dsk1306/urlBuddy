import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  // MARK: - Typealiases

  private typealias ErrorHandler = AppLifecycleSubscribableService.ErrorHandler

  // MARK: - Properties

  var window: UIWindow?

  private lazy var services: Services = DefaultServices()

  private lazy var onError: ErrorHandler = { [weak services] error in
    services?.logger.log(error: error)
  }

  // MARK: - UIWindowSceneDelegate

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    services.handleConnectToScene(with: connectionOptions, onError: onError)
    ImageAsset.onError = onError
    ColorAsset.onError = onError
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    services.handleSceneEnteringBackground(onError: onError)
  }

}
