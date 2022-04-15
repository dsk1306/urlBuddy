import UIKit

final class LinksHistoryEmptyView: BaseView {

  // MARK: - Typealiases

  fileprivate typealias LocalizedString = URLShortener.LocalizedString.EmptyView

  // MARK: - Properties

  private lazy var backgroundImageView = UIImageView() ->> {
    $0.image = ImageAsset.background
    $0.contentMode = .scaleAspectFit
  }

  private lazy var titleLabel = UILabel() ->> {
    $0.text = LocalizedString.title
    $0.textColor = ColorAsset.tuna
    $0.textAlignment = .center
    $0.numberOfLines = 0
    $0.font = .systemFont(ofSize: 20, weight: .semibold)
  }

  private lazy var messageLabel = UILabel() ->> {
    $0.text = LocalizedString.message
    $0.textColor = ColorAsset.tuna
    $0.textAlignment = .center
    $0.numberOfLines = 0
    $0.font = .systemFont(ofSize: 17)
  }

  // MARK: - Base Class

  override func configureSubviews() {
    super.configureSubviews()

    backgroundImageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    backgroundImageView.setContentHuggingPriority(.defaultLow, for: .vertical)
    backgroundImageView.add(to: self) {
      $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: Constant.verticalInset)
      $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: Constant.horizontalInset)
      $1.trailingAnchor.constraint(equalTo: $0.trailingAnchor, constant: Constant.horizontalInset)
    }

    // Text stack view.
    let textStackView = UIStackView() ->> {
      $0.axis = .vertical
      $0.alignment = .fill
      $0.distribution = .fill
      $0.spacing = 4
    }

    textStackView.add(to: self) {
      $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: Constant.horizontalInset)
      $1.trailingAnchor.constraint(equalTo: $0.trailingAnchor, constant: Constant.horizontalInset)
      $0.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: Constant.verticalInset)
      $1.bottomAnchor.constraint(equalTo: $0.bottomAnchor, constant: Constant.verticalInset)
    }

    // Title label.
    titleLabel.addAsArrangedSubview(to: textStackView)
    titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)

    // Message label.
    messageLabel.addAsArrangedSubview(to: textStackView)
    messageLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    messageLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
  }

}

// MARK: - Constants

private extension LinksHistoryEmptyView {

  enum Constant {

    static let horizontalInset: CGFloat = 24
    static let verticalInset: CGFloat = 12

  }

}
