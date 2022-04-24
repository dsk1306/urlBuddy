import UIKit

/// Base class for all view controllers.
class BaseViewController: UIViewController {

  // MARK: - Initialization

  init() {
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Base Class

  override func viewDidLoad() {
    super.viewDidLoad()

    configureSubviews()
    bind()
  }

  // MARK: - Public Methods

  /// Configures view subviews.
  func configureSubviews() {}

  func bind() {}

}
