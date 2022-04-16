import Combine
import CombineExtensions
import Foundation

protocol LinksShortenerViewModelBindable {

  var saveLink: PassthroughRelay<Link> { get }

}

// MARK: -

final class LinksShortenerViewModel: BaseViewModel {

  // MARK: - Input

  struct Input {

    let shorten = PassthroughRelay<Void>()
    let urlTextChanged = PassthroughRelay<String>()

  }

  // MARK: - Output

  struct Output {

    let error: AnyPublisher<Error, Never>
    let emptyURLError: AnyPublisher<Void, Never>
    let shortenedLink: AnyPublisher<Link, Never>
    let isValidURL: AnyPublisher<Bool, Never>

  }

  // MARK: - Properties

  let output: Output
  let input = Input()

  private let linksShortenerService: LinksShortenerService
  private let clipboardService: ClipboardService

  // MARK: - Properties - Relays

  private let urlTextRelay = CurrentValueRelay<String>("")
  private let errorRelay = PassthroughRelay<Error>()
  private let emptyURLErrorRelay = PassthroughRelay<Void>()
  private let shortenedLinkRelay = PassthroughRelay<Link>()
  private let isValidURLRelay = CurrentValueRelay<Bool>(false)

  // MARK: - Initialization

  override init(services: Services, cordinator: RootCoordinator) {
    self.linksShortenerService = services.linksShortener
    self.clipboardService = services.clipboard

    self.output = Output(
      error: errorRelay.prepareToOutput(),
      emptyURLError: emptyURLErrorRelay.prepareToOutput(),
      shortenedLink: shortenedLinkRelay.prepareToOutput(),
      isValidURL: isValidURLRelay.prepareToOutput()
    )

    super.init(services: services, cordinator: cordinator)
  }

  // MARK: - Base Class

  override func bind() {
    super.bind()

    cancellable {
      input.urlTextChanged.subscribe(urlTextRelay)
      input.shorten
        .withLatestFrom(urlTextRelay)
        .compactMap { [weak self] in self?.url(from: $0) }
        .flatMap { [weak self] url in
          self?.shortenerPublisher(for: url) ?? Empty().eraseToAnyPublisher()
        }
        .subscribe(shortenedLinkRelay)
      urlTextRelay
        .map { [weak self] urlString -> Bool in
          do {
            return try URLStringValidator(urlString: urlString).isValid
          } catch {
            self?.log(error: error)
            return false
          }
        }
        .removeDuplicates()
        .subscribe(isValidURLRelay)
      errorRelay
        .sinkValue { [weak cordinator] in cordinator?.showAlert(for: $0) }
      shortenedLinkRelay
        .sinkValue { [weak self] in self?.clipboardService.paste(link: $0) }
    }
  }

}

// MARK: - Public Methods

extension LinksShortenerViewModel {

  func bind(to input: LinksShortenerViewModelBindable) {
    cancellable {
      output.shortenedLink.subscribe(input.saveLink)
    }
  }

}

// MARK: - Private Methods

private extension LinksShortenerViewModel {

  func url(from urlString: String) -> URL? {
    guard !urlString.isEmpty else {
      emptyURLErrorRelay.accept()
      return nil
    }
    guard let url = URL(string: urlString) else {
      errorRelay.accept(LinksShortenerError.badURL)
      return nil
    }
    return url
  }

  func shortenerPublisher(for originalURL: URL) -> AnyPublisher<Link, Never> {
    linksShortenerService.shorten(link: originalURL)
      .map { Link(original: originalURL, shorten: $0) }
      .catch { [weak errorRelay] in errorRelay?.accept($0) }
      .eraseToAnyPublisher()
  }

}
