import UIKit

final class TestsAppDelegate: UIResponder, UIApplicationDelegate {

  // MARK: - UIApplicationDelegate

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    true
  }

  // MARK: - UISceneSession Lifecycle

  func application(_ application: UIApplication,
                   configurationForConnecting connectingSceneSession: UISceneSession,
                   options: UIScene.ConnectionOptions) -> UISceneConfiguration {

    UISceneConfiguration(name: "Tests", sessionRole: connectingSceneSession.role)
  }

}
