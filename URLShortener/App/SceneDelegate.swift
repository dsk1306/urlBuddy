import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	
	// MARK: - Properties
	
	var window: UIWindow?
	
	// MARK: - UIWindowSceneDelegate
	
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let _ = (scene as? UIWindowScene) else { return }
	}
	
	func sceneDidEnterBackground(_ scene: UIScene) {
		(UIApplication.shared.delegate as? AppDelegate)?.saveContext()
	}
	
}
