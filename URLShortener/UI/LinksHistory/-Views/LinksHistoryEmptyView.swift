import UIKit

final class LinksHistoryEmptyView: BaseView {

  // MARK: - Typealiases

  fileprivate typealias LocalizedString = URLShortener.LocalizedString.EmptyView

  // MARK: - Properties

  private lazy var container = UIView()

  private lazy var logoImageView = UIImageView() ->> { logoImageView in
    logoImageView.image = ImageAsset.logo
    logoImageView.contentMode = .scaleAspectFit
  }

  private lazy var backgroundImageView = UIImageView() ->> { backgroundImageView in
    backgroundImageView.image = ImageAsset.background
    backgroundImageView.contentMode = .scaleAspectFit
  }

  private lazy var titleLabel = UILabel() ->> { titleLabel in
    titleLabel.text = LocalizedString.title
    titleLabel.textColor = ColorAsset.tuna
    titleLabel.textAlignment = .center
    titleLabel.numberOfLines = 0
    titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
  }

  private lazy var messageLabel = UILabel() ->> { messageLabel in
    messageLabel.text = LocalizedString.message
    messageLabel.textColor = ColorAsset.tuna
    messageLabel.textAlignment = .center
    messageLabel.numberOfLines = 0
    messageLabel.font = .systemFont(ofSize: 17)
  }

  // MARK: - Base Class

  override func configureSubviews() {
    super.configureSubviews()

    translatesAutoresizingMaskIntoConstraints = false

    container.add(to: self) { container, view in
      container.leadingAnchor.constraint(equalTo: view.leadingMarginAnchor)
      container.topAnchor.constraint(greaterThanOrEqualTo: view.topMarginAnchor)
      view.trailingMarginAnchor.constraint(equalTo: container.trailingAnchor)
      view.bottomMarginAnchor.constraint(greaterThanOrEqualTo: container.bottomAnchor)
      container.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    }

    // Images stack view.
    let imagesStackView = UIStackView() ->> { imagesStackView in
      imagesStackView.axis = .vertical
      imagesStackView.alignment = .fill
      imagesStackView.distribution = .fill
      imagesStackView.spacing = 16
    }

    imagesStackView.add(to: container) { stackView, container in
      stackView.leadingAnchor.constraint(equalTo: container.leadingMarginAnchor)
      container.trailingMarginAnchor.constraint(equalTo: stackView.trailingAnchor)
      stackView.topAnchor.constraint(equalTo: container.topMarginAnchor)
    }

    // Logo image view.
    logoImageView.addAsArrangedSubview(to: imagesStackView)
    logoImageView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    logoImageView.setContentHuggingPriority(.defaultHigh, for: .vertical)

    // Background image view.
    backgroundImageView.addAsArrangedSubview(to: imagesStackView)
    backgroundImageView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    backgroundImageView.setContentHuggingPriority(.defaultHigh, for: .vertical)

    // Text stack view.
    let textStackView = UIStackView() ->> { textStackView in
      textStackView.axis = .vertical
      textStackView.alignment = .fill
      textStackView.distribution = .fill
      textStackView.spacing = 4
    }

    textStackView.add(to: container) { stackView, container in
      stackView.leadingAnchor.constraint(equalTo: container.leadingMarginAnchor, constant: 48)
      container.trailingMarginAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 48)
      stackView.topAnchor.constraint(equalTo: imagesStackView.bottomAnchor, constant: 12)
      container.bottomMarginAnchor.constraint(equalTo: stackView.bottomAnchor)
    }

    // Title label.
    titleLabel.addAsArrangedSubview(to: textStackView)
    titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)

    // Message label.
    messageLabel.addAsArrangedSubview(to: textStackView)
    messageLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    messageLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
  }

}
