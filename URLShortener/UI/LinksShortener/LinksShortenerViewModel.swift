import Combine
import CombineExtensions
import Foundation

protocol LinksShortenerViewModelBindable {

  var saveLink: PassthroughRelay<Link> { get }

}

// MARK: -

extension LinksShortener {

  final class ViewModel: BaseViewModel {

    // MARK: - Input

    struct Input {

      let shorten = PassthroughRelay<Void>()
      let urlTextChanged = PassthroughRelay<String>()

    }

    // MARK: - Output

    struct Output {

      let error: AnyPublisher<Error, Never>
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
    private let shortenedLinkRelay = PassthroughRelay<Link>()
    private let isValidURLRelay = CurrentValueRelay<Bool>(false)

    // MARK: - Initialization

    override init(services: Services, cordinator: RootCoordinator) {
      self.linksShortenerService = services.linksShortener
      self.clipboardService = services.clipboard

      self.output = Output(
        error: errorRelay.prepareToOutput(),
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
        errorRelay
          .sinkValue { [weak cordinator] in cordinator?.showAlert(for: $0) }
        shortenedLinkRelay
          .sinkValue { [weak self] in self?.clipboardService.paste(link: $0) }
        input.shorten
          .withLatestFrom(urlTextRelay)
          .compactMap { [weak self] in self?.url(from: $0) }
          .flatMap { [weak self] url in
            self?.shortenerPublisher(for: url) ?? Empty().eraseToAnyPublisher()
          }
          .subscribe(shortenedLinkRelay)
        urlTextRelay
          .compactMap { [weak self] in self?.isURLStringValid($0) }
          .removeDuplicates()
          .subscribe(isValidURLRelay)
      }
    }

  }

}

// MARK: - Public Methods

extension LinksShortener.ViewModel {

  func bind(to input: LinksShortenerViewModelBindable) {
    cancellable {
      output.shortenedLink.subscribe(input.saveLink)
    }
  }

}

// MARK: - Private Methods

private extension LinksShortener.ViewModel {

  func url(from urlString: String) -> URL? {
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

  func isURLStringValid(_ urlString: String) -> Bool {
    do {
      return try URLStringValidator(urlString: urlString).isValid
    } catch {
      log(error: error)
      return false
    }
  }

}
