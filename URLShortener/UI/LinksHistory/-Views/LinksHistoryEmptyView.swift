import UIKit

final class LinksHistoryEmptyView: BaseView {

  // MARK: - Typealiases

  fileprivate typealias LocalizedString = URLShortener.LocalizedString.EmptyView

  // MARK: - Properties

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

    backgroundImageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    backgroundImageView.setContentHuggingPriority(.defaultLow, for: .vertical)
    backgroundImageView.add(to: self) { backgroundImageView, container in
      backgroundImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 12)
      backgroundImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24)
      container.trailingAnchor.constraint(equalTo: backgroundImageView.trailingAnchor, constant: 24)
    }

    // Text stack view.
    let textStackView = UIStackView() ->> { textStackView in
      textStackView.axis = .vertical
      textStackView.alignment = .fill
      textStackView.distribution = .fill
      textStackView.spacing = 4
    }

    textStackView.add(to: self) { stackView, container in
      stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24)
      container.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 24)
      stackView.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: 12)
      container.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 12)
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
