import Combine
import CombineCocoa
import CombineExtensions
import UIKit
import UIKitExtensions

extension LinksHistory {

  final class ItemCell: BaseCollectionViewCell {

    // MARK: - Properties

    private(set) lazy var copy = copyButton.tapPublisher.eraseToAnyPublisher()
    private(set) lazy var delete = deleteButton.tapPublisher.eraseToAnyPublisher()
    private(set) lazy var shortenedLinkTap = shortenURLButton.tapPublisher.eraseToAnyPublisher()

    // MARK: - Properties - Subviews

    private lazy var copyButton = CopyButton()

    private lazy var originalURLLabel = UILabel() ->> {
      $0.textColor = ColorAsset.tuna
      $0.font = .systemFont(ofSize: 17, weight: .medium)
    }

    private lazy var shortenURLButton = UIButton(configuration: .plain()) ->> {
      $0.configuration?.contentInsets = .zero
      $0.configuration?.titleAlignment = .leading
      $0.contentHorizontalAlignment = .leading
    }

    private lazy var deleteButton = UIButton(type: .system) ->> {
      $0.setImage(ImageAsset.delete, for: .normal)
      $0.tintColor = ColorAsset.tuna
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
      shortenURLButton.addAsArrangedSubview(to: bottomStackView)

      // Copy button.
      copyButton.addAsArrangedSubview(to: bottomStackView) { copyButton, _ in
        copyButton.heightAnchor.constraint(equalToConstant: 39)
      }
    }

    override func reusableBind() {
      super.reusableBind()

      reusableCancellable {
        copy.sinkValue { [weak copyButton] in
          // Update copyButton style.
          copyButton?.type = .copied

          Task { [weak copyButton] in
            // Wait for 2 seconds and revert copyButton style.
            try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
            copyButton?.type = .copy
          }
        }
      }
    }

  }

}

// MARK: - Public Methods

extension LinksHistory.ItemCell {

  func configure(with model: Model) {
    originalURLLabel.text = model.originalURL
    shortenURLButton.configuration?.attributedTitle = Self.shortenURLTitle(with: model)
  }

}

// MARK: - Private Methods

private extension LinksHistory.ItemCell {

  static func shortenURLTitle(with model: Model) -> AttributedString {
    .init(model.shortenURL, attributes: AttributeContainer([
      .font: UIFont.systemFont(ofSize: 17, weight: .medium),
      .foregroundColor: ColorAsset.roman
    ]))
  }

}

// MARK: - Constants

private extension LinksHistory.ItemCell {

  enum Constant {

    static let largeInset: CGFloat = 23
    static let smallInset: CGFloat = 12

  }

}
