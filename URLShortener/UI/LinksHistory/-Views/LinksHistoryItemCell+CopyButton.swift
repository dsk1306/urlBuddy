import UIKit

extension LinksHistoryItemCell {

  final class CopyButton: UIButton {

    // MARK: - State

    enum ButtonType {

      case copy
      case copied

      fileprivate var title: String {
        switch self {
        case .copy:
          return LocalizedString.copy.uppercased()
        case .copied:
          return LocalizedString.copied.uppercased()
        }
      }

      fileprivate var backgroundColor: UIColor {
        switch self {
        case .copied:
          return ColorAsset.martinique
        case .copy:
          return ColorAsset.roman
        }
      }

      fileprivate var isUserInteractionEnabled: Bool {
        switch self {
        case .copied:
          return false
        case .copy:
          return true
        }
      }

    }

    // MARK: - Typealiases

    fileprivate typealias LocalizedString = URLShortener.LocalizedString.LinksHistory

    // MARK: - Properties

    var type = ButtonType.copy {
      didSet {
        updateWithType(animated: true)
      }
    }

    // MARK: - Initialization

    convenience init() {
      self.init(configuration: UIButton.Configuration.filled())

      configuration?.baseForegroundColor = .white

      updateWithType(animated: false)
    }

  }

}

// MARK: - Private Methods

private extension LinksHistoryItemCell.CopyButton {

  func updateWithType(animated: Bool) {
    isUserInteractionEnabled = type.isUserInteractionEnabled
    configuration?.baseBackgroundColor = type.backgroundColor

    let attributes = AttributeContainer([
      .foregroundColor: UIColor.white,
      .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
    ])
    configuration?.attributedTitle = .init(type.title, attributes: attributes)
  }

}
