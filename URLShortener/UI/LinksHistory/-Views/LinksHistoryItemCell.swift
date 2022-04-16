import Combine
import CombineExtensions
import UIKit

extension LinksHistory {

  final class ItemCell: BaseCollectionViewCell {

    // MARK: - Properties

    private(set) lazy var copy = copyRelay.eraseToAnyPublisher()
    private(set) lazy var delete = deleteRelay.eraseToAnyPublisher()

    private lazy var copyRelay = PassthroughRelay<Void>()
    private lazy var deleteRelay = PassthroughRelay<Void>()

    // MARK: - Properties - Subviews

    private lazy var originalURLLabel = UILabel() ->> {
      $0.textColor = ColorAsset.tuna
      $0.font = .systemFont(ofSize: 17)
    }

    private lazy var shortenURLLabel = UILabel() ->> {
      $0.textColor = ColorAsset.roman
      $0.font = .systemFont(ofSize: 17)
    }

    private lazy var copyButton = CopyButton() ->> {
      $0.addTarget(self, action: #selector(copyButtonTouchUpInside), for: .touchUpInside)
    }

    private lazy var deleteButton = UIButton(type: .system) ->> {
      $0.setImage(ImageAsset.delete, for: .normal)
      $0.tintColor = ColorAsset.tuna
      $0.addTarget(self, action: #selector(deleteButtonTouchUpInside), for: .touchUpInside)
    }

    // MARK: - Base Class

    override func configureSubviews() {
      super.configureSubviews()

      contentView.backgroundColor = .white

      // Original URL stack view.
      let originalURLStackView = UIStackView() ->> {
        $0.alignment = .fill
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.spacing = 8
      }

      originalURLStackView.add(to: contentView) {
        $0.leadingAnchor.constraint(equalTo: $1.leadingMarginAnchor, constant: Constant.largeInset)
        $1.trailingMarginAnchor.constraint(equalTo: $0.trailingAnchor, constant: Constant.largeInset)
        $0.topAnchor.constraint(equalTo: $1.topMarginAnchor, constant: Constant.largeInset)
      }

      // Original URL label.
      originalURLLabel.addAsArrangedSubview(to: originalURLStackView)

      // Delete button.
      deleteButton.addAsArrangedSubview(to: originalURLStackView) { deleteButton, _ in
        deleteButton.widthAnchor.constraint(equalTo: deleteButton.heightAnchor)
      }

      // Separator.
      let separatorView = UIView() ->> {
        $0.backgroundColor = ColorAsset.tuna
      }

      separatorView.add(to: contentView) {
        $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
        $1.trailingAnchor.constraint(equalTo: $0.trailingAnchor)
        $0.topAnchor.constraint(equalTo: originalURLStackView.bottomAnchor, constant: Constant.smallInset)
        $0.heightAnchor.constraint(equalToConstant: 1)
      }

      // Bottom stack view.
      let bottomStackView = UIStackView() ->> {
        $0.alignment = .fill
        $0.axis = .vertical
        $0.distribution = .fill
        $0.spacing = 23
      }

      bottomStackView.add(to: contentView) {
        $0.leadingAnchor.constraint(equalTo: $1.leadingMarginAnchor, constant: Constant.largeInset)
        $1.trailingMarginAnchor.constraint(equalTo: $0.trailingAnchor, constant: Constant.largeInset)
        $0.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: Constant.smallInset)
        $1.bottomMarginAnchor.constraint(equalTo: $0.bottomAnchor, constant: Constant.largeInset)
      }

      // Shorten URL label.
      shortenURLLabel.addAsArrangedSubview(to: bottomStackView)

      // Copy button.
      copyButton.addAsArrangedSubview(to: bottomStackView) { copyButton, _ in
        copyButton.heightAnchor.constraint(equalToConstant: 39)
      }
    }

  }

}

// MARK: - Public Methods

extension LinksHistory.ItemCell {

  func configure(with model: ItemModel) {
    originalURLLabel.text = model.originalURL
    shortenURLLabel.text = model.shortenURL
  }

}

// MARK: - Private Methods

private extension LinksHistory.ItemCell {

  @objc
  func copyButtonTouchUpInside() {
    copyRelay.accept()

    // Update copyButton style.
    copyButton.type = .copied

    Task {
      // Wait for 2 seconds and revert copyButton style.
      try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
      copyButton.type = .copy
    }
  }

  @objc
  func deleteButtonTouchUpInside() {
    deleteRelay.accept()
  }

}

// MARK: - Constants

private extension LinksHistory.ItemCell {

  enum Constant {

    static let largeInset: CGFloat = 23
    static let smallInset: CGFloat = 12

  }

}
