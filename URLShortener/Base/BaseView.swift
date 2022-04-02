import UIKit

/// Base class for all views.
class BaseView: UIView {

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)

    configureSubviews()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Public

  /// Configures cell subviews.
  func configureSubviews() {}
  
}
