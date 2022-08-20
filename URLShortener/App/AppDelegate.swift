import CoreData
import UIKit

final class AppDelegate: UIResponder, UIApplicationDelegate {

  // MARK: - Typealiases

  typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]?

  // MARK: - UIApplicationDelegate

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: LaunchOptions) -> Bool {

    true
  }

  func application(_ application: UIApplication,
                   configurationForConnecting connectingSceneSession: UISceneSession,
                   options: UIScene.ConnectionOptions) -> UISceneConfiguration {

    UISceneConfiguration(name: "App", sessionRole: connectingSceneSession.role)
  }

}
