import Combine
import CombineExtensions
import UIKit

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
      let clipboardURLString: AnyPublisher<String, Never>

    }

    // MARK: - Properties

    let output: Output
    let input = Input()

    private let linksShortenerService: LinksShortenerService
    private let clipboardService: ClipboardService

    private var clipboardString: String? {
      do {
        guard let string = clipboardService.string else { return nil }
        guard try URLStringValidator(urlString: string).isValid else { return nil }
        return string
      } catch {
        return nil
      }
    }

    // MARK: - Properties - Relays

    private let urlTextRelay = CurrentValueRelay<String>("")
    private let errorRelay = PassthroughRelay<Error>()
    private let shortenedLinkRelay = PassthroughRelay<Link>()
    private let isValidURLRelay = CurrentValueRelay<Bool>(false)
    private let clipboardURLStringRelay = PassthroughRelay<String>()

    // MARK: - Initialization

    override init(services: Services, cordinator: RootCoordinator) {
      self.linksShortenerService = services.linksShortener
      self.clipboardService = services.clipboard

      self.output = Output(
        error: errorRelay.prepareToOutput(),
        shortenedLink: shortenedLinkRelay.prepareToOutput(),
        isValidURL: isValidURLRelay.prepareToOutput(),
        clipboardURLString: clipboardURLStringRelay.prepareToOutput()
      )

      super.init(services: services, cordinator: cordinator)
    }

    // MARK: - Base Class

    override func bind() {
      super.bind()

      bindRelays()

      cancellable {
        input.urlTextChanged
          .subscribe(urlTextRelay)
        input.shorten
          .withLatestFrom(urlTextRelay)
          .compactMap { [weak self] in self?.url(from: $0) }
          .flatMap { [weak self] url in
            self?.shortenerPublisher(for: url) ?? Empty().eraseToAnyPublisher()
          }
          .subscribe(shortenedLinkRelay)
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
          .withLatestFrom(urlTextRelay)
          .filter { $0.isEmpty }
          .compactMap { [weak self] _ in self?.clipboardString }
          .subscribe(clipboardURLStringRelay)
      }
    }

  }

}

// MARK: - Public Methods

extension LinksShortener.ViewModel {

  func bind(to input: LinksShortenerViewModelBindable) {
    cancellable {
      output.shortenedLink
        .subscribe(input.saveLink)
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

// MARK: - Private Methods - Binding

private extension LinksShortener.ViewModel {

  func bindRelays() {
    cancellable {
      clipboardURLStringRelay
        .subscribe(urlTextRelay)
      errorRelay
        .sinkValue { [weak cordinator] in await cordinator?.showAlert(for: $0) }
      shortenedLinkRelay
        .sinkValue { [weak self] in self?.clipboardService.paste(link: $0) }
      shortenedLinkRelay
        .mapToValue("")
        .subscribe(urlTextRelay)
      urlTextRelay
        .compactMap { [weak self] in self?.isURLStringValid($0) }
        .subscribe(isValidURLRelay)
    }
  }

}
