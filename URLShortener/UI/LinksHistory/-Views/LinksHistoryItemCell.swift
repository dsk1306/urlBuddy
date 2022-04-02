import Combine
import CombineExtensions
import UIKit

final class LinksHistoryItemCell: BaseCollectionViewCell {

  // MARK: - ItemModel

  struct ItemModel {

    let originalURL: String
    let shortenURL: String

    init(link: Link) {
      originalURL = link.originalString
      shortenURL = link.shortenString
    }

  }

  // MARK: - Properties

  private(set) lazy var copy = copyRelay.eraseToAnyPublisher()
  private(set) lazy var delete = deleteRelay.eraseToAnyPublisher()

  private lazy var copyRelay = PassthroughRelay<Void>()
  private lazy var deleteRelay = PassthroughRelay<Void>()

  // MARK: - Properties - Subviews

  private lazy var originalURLLabel = UILabel() ->> { originalURLLabel in
    originalURLLabel.textColor = ColorAsset.tuna
    originalURLLabel.font = .systemFont(ofSize: 17)
  }

  private lazy var shortenURLLabel = UILabel() ->> { shortenURLLabel in
    shortenURLLabel.textColor = ColorAsset.turquoise
    shortenURLLabel.font = .systemFont(ofSize: 17)
  }

  private lazy var copyButton = CopyButton() ->> { copyButton in
    copyButton.configure(for: .copy)
    copyButton.addTarget(self, action: #selector(copyButtonTouchUpInside), for: .touchUpInside)
  }

  private lazy var deleteButton = UIButton(type: .system) ->> { deleteButton in
    deleteButton.setImage(ImageAsset.delete, for: .normal)
    deleteButton.tintColor = ColorAsset.tuna
    deleteButton.addTarget(self, action: #selector(deleteButtonTouchUpInside), for: .touchUpInside)
  }

  // MARK: - Base Class

  override func configureSubviews() {
    super.configureSubviews()

    contentView.backgroundColor = .white

    // Original URL stack view.
    let originalURLStackView = UIStackView() ->> { originalURLStackView in
      originalURLStackView.alignment = .fill
      originalURLStackView.axis = .horizontal
      originalURLStackView.distribution = .fill
      originalURLStackView.spacing = 8
    }

    originalURLStackView.add(to: contentView) { stackView, contentView in
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingMarginAnchor, constant: 23)
      contentView.trailingMarginAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 23)
      stackView.topAnchor.constraint(equalTo: contentView.topMarginAnchor, constant: 23)
    }

    // Original URL label.
    originalURLLabel.addAsArrangedSubview(to: originalURLStackView)

    // Delete button.
    deleteButton.addAsArrangedSubview(to: originalURLStackView) { deleteButton, _ in
      deleteButton.widthAnchor.constraint(equalTo: deleteButton.heightAnchor)
    }

    // Separator.
    let separatorView = UIView() ->> { separatorView in
      separatorView.backgroundColor = ColorAsset.tuna
    }

    separatorView.add(to: contentView) { separatorView, contentView in
      separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
      contentView.trailingAnchor.constraint(equalTo: separatorView.trailingAnchor)
      separatorView.topAnchor.constraint(equalTo: originalURLStackView.bottomAnchor, constant: 12)
      separatorView.heightAnchor.constraint(equalToConstant: 1)
    }

    // Bottom stack view.
    let bottomStackView = UIStackView() ->> { bottomStackView in
      bottomStackView.alignment = .fill
      bottomStackView.axis = .vertical
      bottomStackView.distribution = .fill
      bottomStackView.spacing = 23
    }

    bottomStackView.add(to: contentView) { bottomStackView, contentView in
      bottomStackView.leadingAnchor.constraint(equalTo: contentView.leadingMarginAnchor, constant: 23)
      contentView.trailingMarginAnchor.constraint(equalTo: bottomStackView.trailingAnchor, constant: 23)
      bottomStackView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 12)
      contentView.bottomMarginAnchor.constraint(equalTo: bottomStackView.bottomAnchor, constant: 23)
    }

    // Shorten URL label.
    shortenURLLabel.addAsArrangedSubview(to: bottomStackView)

    // Copy button.
    copyButton.addAsArrangedSubview(to: bottomStackView) { copyButton, _ in
      copyButton.heightAnchor.constraint(equalToConstant: 39)
    }
  }

}

// MARK: - Public Methods

extension LinksHistoryItemCell {

  func configure(with model: ItemModel) {
    originalURLLabel.text = model.originalURL
    shortenURLLabel.text = model.shortenURL
  }

}

// MARK: - Private Methods

private extension LinksHistoryItemCell {

  @objc
  func copyButtonTouchUpInside() {
    copyRelay.accept()

    // Update copyButton style.
    copyButton.configure(for: .copied)

    Task {
      // Wait for 2 seconds and revert copyButton style.
      try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
      copyButton.configure(for: .copy)
    }
  }

  @objc
  func deleteButtonTouchUpInside() {
    deleteRelay.accept()
  }

}
