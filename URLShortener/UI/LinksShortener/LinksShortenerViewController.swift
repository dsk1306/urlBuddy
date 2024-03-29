import Combine
import CombineExtensions
import UIKit
import UIKitExtensions

extension LinksShortener {

  final class ViewController: BaseViewController {

    // MARK: - Typealiases

    fileprivate typealias LocalizedString = URLShortener.LocalizedString.LinkShortener

    // MARK: - Properties

    private let viewModel: ViewModel

    private let cancellable = CombineCancellable()

    private lazy var shortenButtonConfiguration: UIButton.Configuration = {
      var configuration = UIButton.Configuration.filled()
      configuration.baseBackgroundColor = ColorAsset.roman
      configuration.attributedTitle = Self.shortenButtonTitle(for: .disabled)
      return configuration
    }()

    // MARK: - Properties - Subviews

    private lazy var shortenButton = ActivityIndicatorButton(configuration: shortenButtonConfiguration) ->> {
      $0.configurationUpdateHandler = {
        $0.configuration?.attributedTitle = Self.shortenButtonTitle(for: $0.state)
      }
    }

    private lazy var urlTextField = UITextField() ->> {
      $0.layer.cornerRadius = Constant.urlTextFieldCornerRadius
      $0.backgroundColor = .white
      $0.textAlignment = .center
      $0.autocorrectionType = .no
      $0.autocapitalizationType = .none
      $0.attributedPlaceholder = Constant.urlTextFieldPlaceholder
      $0.keyboardType = .URL
      $0.clearButtonMode = .whileEditing
    }

    // MARK: - Initialization

    init(viewModel: ViewModel) {
      self.viewModel = viewModel

      super.init()
    }

    // MARK: - Base Class

    override func configureSubviews() {
      super.configureSubviews()

      view.backgroundColor = ColorAsset.martinique
      view.setContentHuggingPriority(.defaultLow, for: .vertical)
      view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

      // Stack view.
      let stackView = UIStackView() ->> {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 16
      }

      stackView.add(to: view) {
        $0.leadingAnchor.constraint(equalTo: $1.leadingSafeAnchor, constant: Constant.inset)
        $1.trailingSafeAnchor.constraint(equalTo: $0.trailingAnchor, constant: Constant.inset)
        $1.bottomSafeAnchor.constraint(equalTo: $0.bottomAnchor, constant: Constant.inset)
        $0.topAnchor.constraint(equalTo: $1.topSafeAnchor, constant: Constant.inset)
      }

      // URL text field.
      urlTextField.addAsArrangedSubview(to: stackView) { urlTextField, _ in
        urlTextField.heightAnchor.constraint(equalToConstant: 49)
      }

      // Shorten button.
      shortenButton.addAsArrangedSubview(to: stackView)
    }

    override func bind() {
      super.bind()

      viewModel.bind()
      bindOutput()

      cancellable {
        shortenButton.tapPublisher
          .subscribe(viewModel.input.shorten)
        shortenButton.tapPublisher
          .sinkValue { [weak shortenButton] in
            shortenButton?.configureLoadingState(isLoading: true)
          }
        urlTextField.textPublisher
          .map { $0 ?? "" }
          .subscribe(viewModel.input.urlTextChanged)
      }
    }

  }

}

// MARK: - Private Methods

private extension LinksShortener.ViewController {

  static func shortenButtonTitle(for state: UIControl.State) -> AttributedString {
    let color: UIColor
    switch state {
    case .normal:
      color = .white
    default:
      color = .lightGray
    }

    let attributes = AttributeContainer([
      .foregroundColor: color,
      .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
    ])
    return AttributedString(LocalizedString.cta, attributes: attributes)
  }

}

// MARK: - Private Methods - Binding

private extension LinksShortener.ViewController {

  func bindOutput() {
    cancellable {
      viewModel.output.isValidURL
        .assign(to: \.isEnabled, on: shortenButton, ownership: .weak)
      viewModel.output.clipboardURLString
        .map { $0 }
        .assign(to: \.text, on: urlTextField, ownership: .weak)
      viewModel.output.shortenedLink
        .sinkValue { [weak urlTextField] _ in
          urlTextField?.text = nil
          urlTextField?.endEditing(true)
        }
      Publishers.Merge(
        viewModel.output.error.mapToVoid(),
        viewModel.output.shortenedLink.mapToVoid()
      )
      .sinkValue { [weak shortenButton] in
        shortenButton?.configureLoadingState(isLoading: false)
      }
    }
  }

}

// MARK: - Constants

private extension LinksShortener.ViewController {

  enum Constant {

    static let urlTextFieldCornerRadius: CGFloat = 6
    static let inset: CGFloat = 32

    static let urlTextFieldPlaceholder = NSAttributedString(
      string: LocalizedString.placeholder,
      attributes: [
        .paragraphStyle: urlTextFieldParagraphStyle,
        .font: UIFont.systemFont(ofSize: 17)
      ]
    )

    private static let urlTextFieldParagraphStyle = NSMutableParagraphStyle() ->> {
      $0.alignment = .center
    }

  }

}
