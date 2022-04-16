import UIKit

final class RootCoordinator {

  // MARK: - Properties

  private let services: Services

  private weak var window: UIWindow?

  // MARK: - Initialization

  init(window: UIWindow?, services: Services) {
    self.window = window
    self.services = services
  }

}

// MARK: - Public Methods

extension RootCoordinator {

  func start() {
    guard let window = window else {
      services.logger.log(error: "Expected UIWindow object in \(#function) but found nil instead")
      return
    }

    let historyViewModel = LinksHistory.ViewModel(
      services: services,
      cordinator: self
    )
    let historyController = LinksHistory.ViewController(viewModel: historyViewModel)
    let navigationController = UINavigationController(rootViewController: historyController)

    let shortenerViewModel = LinksShortener.ViewModel(
      services: services,
      cordinator: self
    )
    let shortenerController = LinksShortener.ViewController(viewModel: shortenerViewModel)
    historyController.addChild(shortenerController)

    shortenerViewModel.bind(to: historyViewModel.input)

    window.rootViewController = navigationController
    window.makeKeyAndVisible()
  }

  func showAlert(for error: Error) {
    typealias LocalizedString = URLShortener.LocalizedString.ErrorAlert

    let alert = UIAlertController(
      title: LocalizedString.title,
      message: error.localizedDescription,
      preferredStyle: .alert
    )
    alert.addAction(.init(title: LocalizedString.okAction, style: .cancel))

    DispatchQueue.main.async { [weak window] in
      window?.rootViewController?.present(alert, animated: true)
    }
  }

}
