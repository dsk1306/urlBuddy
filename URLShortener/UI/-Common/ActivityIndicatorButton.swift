import UIKit

final class ActivityIndicatorButton: UIButton {

  // MARK: - Properties

  private weak var activityIndicatorView: UIActivityIndicatorView?

}

// MARK: - Public Methods

extension ActivityIndicatorButton {

  func configureLoadingState(isLoading: Bool) {
    isLoading ? enableLoadingState() : disableLoadingState()
  }

}

// MARK: - Private Methods

private extension ActivityIndicatorButton {

  func enableLoadingState() {
    isUserInteractionEnabled = false

    titleLabel?.layer.opacity = 0

    let activity = UIActivityIndicatorView(style: .medium)
    activity.startAnimating()
    activityIndicatorView = activity

    activity.add(to: self) { activity, view in
      activity.centerXAnchor.constraint(equalTo: view.centerXAnchor)
      activity.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    }
  }

  func disableLoadingState() {
    isUserInteractionEnabled = true
    activityIndicatorView?.removeFromSuperview()
    titleLabel?.layer.opacity = 1
  }

}
