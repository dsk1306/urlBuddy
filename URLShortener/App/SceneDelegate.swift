import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  // MARK: - Typealiases

  private typealias ErrorHandler = AppLifecycleSubscribableService.ErrorHandler

  // MARK: - Properties

  var window: UIWindow?

  private lazy var services: Services = DefaultServices()
  private lazy var coordinator = RootCoordinator(window: window, services: services)

  private lazy var onError: ErrorHandler = { [weak services] error in
    services?.logger.log(error: error)
  }

  // MARK: - UIWindowSceneDelegate

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    services.handleConnectToScene(with: connectionOptions, onError: onError)
    ImageAsset.onError = onError
    ColorAsset.onError = onError

    guard let window = makeWindow(with: scene) else { return }
    self.window = window

    coordinator.start()
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    services.handleSceneEnteringBackground(onError: onError)
  }

}

// MARK: - Private Methods

private extension SceneDelegate {

  func makeWindow(with scene: UIScene) -> UIWindow? {
    guard let scene = scene as? UIWindowScene else {
      services.logger.log(error: "Unexpected scene in \(#function)")
      return nil
    }

    let window = UIWindow(windowScene: scene)
    window.backgroundColor = .systemBackground
    return window
  }

}
