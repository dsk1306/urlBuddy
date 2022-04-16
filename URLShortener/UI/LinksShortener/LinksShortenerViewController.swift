import Combine
import CombineExtensions
import UIKit

final class LinksShortenerViewController: UIViewController {

  // MARK: - Typealiases

  fileprivate typealias LocalizedString = URLShortener.LocalizedString.LinkShortener

  // MARK: - Properties

  private let viewModel: LinksShortenerViewModel

  private let cancellable = CombineCancellable()

  // MARK: - Properties - Subviews

  private lazy var shortenButtonConfiguration: UIButton.Configuration = {
    var configuration = UIButton.Configuration.filled()
    configuration.baseBackgroundColor = ColorAsset.roman
    configuration.attributedTitle = Self.shortenButtonTitle(for: .disabled)
    return configuration
  }()

  private lazy var shortenButton = ActivityIndicatorButton(configuration: shortenButtonConfiguration) ->> {
    $0.addTarget(self, action: #selector(shortenButtonTouchUpInside), for: .touchUpInside)
    $0.configurationUpdateHandler = {
      $0.configuration?.attributedTitle = Self.shortenButtonTitle(for: $0.state)
    }
  }

  private lazy var urlTextField = LinksShortenerURLTextField() ->> {
    $0.configure(for: .normal)
    $0.addTarget(self, action: #selector(urlTextFieldEditingChanged(sender:)), for: .editingChanged)
  }

  // MARK: - Initialization

  init(viewModel: LinksShortenerViewModel) {
    self.viewModel = viewModel

    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Base Class

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = ColorAsset.martinique
    view.setContentHuggingPriority(.defaultLow, for: .vertical)
    view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

    configureSubviews()
    bind()
  }

}

// MARK: - Private Methods

private extension LinksShortenerViewController {

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

  @objc
  func shortenButtonTouchUpInside() {
    shortenButton.configureLoadingState(isLoading: true)
    viewModel.input.shorten.accept()
  }

  @objc
  func urlTextFieldEditingChanged(sender: UITextField) {
    urlTextField.configure(for: .normal)
    viewModel.input.urlTextChanged.accept(sender.text ?? "")
  }

  func configureSubviews() {
    // Stack view.
    let stackView = UIStackView() ->> {
      $0.axis = .vertical
      $0.distribution = .fillEqually
      $0.alignment = .fill
      $0.spacing = 16
    }

    stackView.add(to: view) {
      $0.leadingAnchor.constraint(equalTo: $1.leadingSafeAnchor, constant: 48)
      $1.trailingSafeAnchor.constraint(equalTo: $0.trailingAnchor, constant: 48)
      $1.bottomSafeAnchor.constraint(equalTo: $0.bottomAnchor, constant: 50)
      $0.topAnchor.constraint(equalTo: $1.topSafeAnchor, constant: 46)
    }

    // URL text field.
    urlTextField.addAsArrangedSubview(to: stackView) { urlTextField, _ in
      urlTextField.heightAnchor.constraint(equalToConstant: 49)
    }

    // Shorten button.
    shortenButton.addAsArrangedSubview(to: stackView)
  }

}

// MARK: - Private Methods - Binding

private extension LinksShortenerViewController {

  func bind() {
    viewModel.bind()

    cancellable {
      viewModel.output.emptyURLError
        .sinkValue { [weak self] in self?.urlTextField.configure(for: .emptyLink) }
      viewModel.output.isValidURL
        .assign(to: \.isEnabled, on: shortenButton, ownership: .weak)
      Publishers.Merge3(
        viewModel.output.error.map { _ in () },
        viewModel.output.emptyURLError,
        viewModel.output.shortenedLink.map { _ in () }
      )
      .sinkValue { [weak shortenButton] in shortenButton?.configureLoadingState(isLoading: false) }
    }
  }

}
