import UIKit

extension LinksHistory.ItemCell {

  final class CopyButton: UIButton {

    // MARK: - Typealiases

    fileprivate typealias LocalizedString = URLShortener.LocalizedString.LinksHistory

    // MARK: - Properties

    var type = ButtonState.copy {
      didSet {
        updateWithType()
      }
    }

    // MARK: - Initialization

    convenience init() {
      self.init(configuration: UIButton.Configuration.filled())

      configuration?.baseForegroundColor = .white

      updateWithType()
    }

  }

}

// MARK: - Private Methods

private extension LinksHistory.ItemCell.CopyButton {

  func updateWithType() {
    isUserInteractionEnabled = type.isUserInteractionEnabled
    configuration?.baseBackgroundColor = type.backgroundColor

    let attributes = AttributeContainer([
      .foregroundColor: UIColor.white,
      .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
    ])
    configuration?.attributedTitle = .init(type.title, attributes: attributes)
  }

}

// MARK: - ButtonState

extension LinksHistory.ItemCell.CopyButton {

  enum ButtonState {

    case copy
    case copied

    fileprivate var title: String {
      switch self {
      case .copy:
        return LocalizedString.copy
      case .copied:
        return LocalizedString.copied
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

}
