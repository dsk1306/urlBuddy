import UIKit

final class ActivityIndicatorButton: UIButton {

  // MARK: - Properties

  private weak var activityIndicatorView: UIActivityIndicatorView?

}

// MARK: - Public Methods

extension ActivityIndicatorButton {

  func configureLoadingState(isLoading: Bool) {
    if isLoading {
      enableLoadingState()
    } else {
      disableLoadingState()
    }
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

    activity.add(to: self) {
      $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
      $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
    }
  }

  func disableLoadingState() {
    isUserInteractionEnabled = true
    activityIndicatorView?.removeFromSuperview()
    titleLabel?.layer.opacity = 1
  }

}
