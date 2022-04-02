import Combine
import CombineExtensions
import Foundation

protocol LinksShortenerViewModelBindable {

  var saveLink: PassthroughRelay<Link> { get }

}

// MARK: -

final class LinksShortenerViewModel {

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

  }

  // MARK: - Properties

  let output: Output
  let input = Input()

  private weak var cordinator: RootCoordinator?

  private let linksShortenerService: LinksShortenerService
  private let clipboardService: ClipboardService

  private let cancellable = CombineCancellable()

  // MARK: - Properties - Relays

  private let urlTextRelay = CurrentValueRelay<String>("")
  private let errorRelay = PassthroughRelay<Error>()
  private let emptyURLErrorRelay = PassthroughRelay<Void>()
  private let shortenedLinkRelay = PassthroughRelay<Link>()

  // MARK: - Initialization

  init(linksShortenerService: LinksShortenerService, clipboardService: ClipboardService, cordinator: RootCoordinator) {
    self.linksShortenerService = linksShortenerService
    self.clipboardService = clipboardService
    self.cordinator = cordinator

    self.output = Output(
      error: errorRelay.prepareToOutput(),
      emptyURLError: emptyURLErrorRelay.prepareToOutput(),
      shortenedLink: shortenedLinkRelay.prepareToOutput()
    )

    bind()
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

// MARK: - Private Methods - Binding

private extension LinksShortenerViewModel {

  func bind() {
    cancellable {
      input.urlTextChanged.subscribe(urlTextRelay)
      input.shorten
        .withLatestFrom(urlTextRelay)
        .compactMap { [weak self] in self?.url(from: $0) }
        .flatMap { [weak self] url in
          self?.shortenerPublisher(for: url) ?? Empty().eraseToAnyPublisher()
        }
        .subscribe(shortenedLinkRelay)
      errorRelay
        .sink { [weak cordinator] in cordinator?.showAlert(for: $0) }
      shortenedLinkRelay
        .sink { [weak self] in self?.clipboardService.paste(link: $0) }
    }
  }

}
