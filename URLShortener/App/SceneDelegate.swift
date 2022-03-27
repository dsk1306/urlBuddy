import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  // MARK: - Properties

  var window: UIWindow?

  private lazy var services = Services()

  private lazy var onError: (Error) -> Void = { error in
    // TODO: Handle Error
    print(error.localizedDescription)
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
