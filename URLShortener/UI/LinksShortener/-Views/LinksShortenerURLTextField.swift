import UIKit

final class LinksShortenerURLTextField: UITextField {

  // MARK: - State

  enum State {

    case normal
    case emptyLink

    private typealias LocalizedString = URLShortener.LocalizedString.LinkShortener

    private static let paragraphStyle = NSMutableParagraphStyle() ->> {
      $0.alignment = .center
    }

    private static let commonAttributes: [NSAttributedString.Key: Any] = [
      .paragraphStyle: paragraphStyle,
      .font: UIFont.systemFont(ofSize: 17)
    ]

    fileprivate var borderColor: CGColor {
      switch self {
      case .normal:
        return UIColor.clear.cgColor
      case .emptyLink:
        return ColorAsset.сarnation.cgColor
      }
    }

    fileprivate var attributedPlaceholder: NSAttributedString {
      switch self {
      case .normal:
        return .init(string: LocalizedString.placeholder, attributes: Self.commonAttributes)
      case .emptyLink:
        let attributes = [.foregroundColor: ColorAsset.сarnation]
          .merging(Self.commonAttributes) { param, _ in param }
        return .init(string: LocalizedString.emptyLinkError, attributes: attributes)
      }
    }

  }

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)

    layer.borderWidth = 1
    backgroundColor = .white
    textAlignment = .center
    autocorrectionType = .no
    autocapitalizationType = .none
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}

// MARK: - Public Methods

extension LinksShortenerURLTextField {

  func configure(for state: State) {
    UIView.animate(withDuration: 0.5, delay: 0) { [self] in
      layer.borderColor = state.borderColor
      attributedPlaceholder = state.attributedPlaceholder
    }
  }

}
