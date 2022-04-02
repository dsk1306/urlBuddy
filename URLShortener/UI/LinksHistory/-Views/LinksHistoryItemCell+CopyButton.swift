import UIKit

extension LinksHistoryItemCell {

  final class CopyButton: UIButton {

    // MARK: - State

    enum State {

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
          return ColorAsset.turquoise
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

    // MARK: - Initialization

    convenience init() {
      self.init(type: .system)
    }

  }

}

// MARK: - Public Methods

extension LinksHistoryItemCell.CopyButton {

  func configure(for state: State) {
    setTitleColor(.white, for: .normal)
    titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)

    UIView.animate(withDuration: 0.5) { [self] in
      setTitle(state.title, for: .normal)
      backgroundColor = state.backgroundColor
      isUserInteractionEnabled = state.isUserInteractionEnabled
    }
  }

}
