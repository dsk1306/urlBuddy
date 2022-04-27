import Combine
import CombineExtensions
import Foundation

extension LinksHistory {

  final class ViewModel: BaseViewModel {

    // MARK: - Input

    struct Input: LinksShortenerViewModelBindable {

      let copyLink = PassthroughRelay<Link>()
      let deleteLink = PassthroughRelay<Link>()
      let saveLink = PassthroughRelay<Link>()
      let openLink = PassthroughRelay<URL>()

    }

    // MARK: - Output

    struct Output {

      typealias SavedLinksPublisher = AnyPublisher<[Link], Never>

      let savedLinks: SavedLinksPublisher

    }

    // MARK: - Properties

    let output: Output
    let input = Input()

    private let persistenceService: PersistenceService
    private let clipboardService: ClipboardService

    // MARK: - Properties - Relays

    private let errorRelay = PassthroughRelay<Error>()
    private let savedLinksRelay = CurrentValueRelay<[Link]>([])

    // MARK: - Initialization

    override init(services: Services, cordinator: RootCoordinator) {
      self.persistenceService = services.persistence
      self.clipboardService = services.clipboard

      self.output = Output(
        savedLinks: savedLinksRelay.removeDuplicates().prepareToOutput()
      )

      super.init(services: services, cordinator: cordinator)
    }

    // MARK: - Base Class

    override func bind() {
      super.bind()

      cancellable {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)
          .debounce(for: Constant.dataReloadDebounceTime, scheduler: RunLoop.main)
          .map { _ in () }
          .prepend(())
          .flatMap { [weak self] in
            self?.fetchedLinks() ?? Empty().eraseToAnyPublisher()
          }
          .subscribe(savedLinksRelay)
        input.copyLink
          .sinkValue { [weak self] in self?.clipboardService.paste(link: $0) }
        input.deleteLink
          .sinkValue { [weak self] in await self?.delete(link: $0) }
        input.saveLink
          .sinkValue { [weak self] in await self?.save(link: $0) }
        errorRelay
          .sinkValue { [weak cordinator] in await cordinator?.showAlert(for: $0) }
        input.openLink
          .sinkValue { [weak cordinator] in await cordinator?.open(link: $0) }
      }
    }

  }

}

// MARK: - Private Methods

private extension LinksHistory.ViewModel {

  func fetchedLinks() -> AnyPublisher<[Link], Never> {
    persistenceService.fetchLinks()
      .catch { [weak self] in self?.errorRelay.accept($0) }
      .eraseToAnyPublisher()
  }

  func delete(link: Link) async {
    do {
      try await self.persistenceService.delete(link: link)
    } catch {
      self.errorRelay.accept(error)
    }
  }

  func save(link: Link) async {
    do {
      if var link = try await self.persistenceService.fetchLinks(withOriginalURL: link.originalString).first {
        link.modified = Date()
        try await self.persistenceService.edit(link: link)
      } else {
        try await self.persistenceService.save(link: link)
      }
    } catch {
      self.errorRelay.accept(error)
    }
  }

}

// MARK: - Constants

private extension LinksHistory.ViewModel {

  enum Constant {

    static let dataReloadDebounceTime = RunLoop.SchedulerTimeType.Stride(0.25)

  }

}
