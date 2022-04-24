import Combine
import CombineExtensions
import UIKit

/// Base class for all collection view cells.
class BaseCollectionViewCell: UICollectionViewCell {

  // MARK: - Properties

  private(set) var reusableCancellable = CombineCancellable()

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)

    configureSubviews()
    reusableBind()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Base Class

  override func prepareForReuse() {
    super.prepareForReuse()

    reusableCancellable = CombineCancellable()
    reusableBind()
  }

  // MARK: - Public

  /// Configures cell subviews.
  func configureSubviews() {}

  func reusableBind() {}

}
