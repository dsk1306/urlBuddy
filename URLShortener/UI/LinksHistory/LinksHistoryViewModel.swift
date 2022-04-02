import Combine
import CombineExtensions
import Foundation

final class LinksHistoryViewModel {

  // MARK: - Input

  struct Input: LinksShortenerViewModelBindable {

    let copyLink = PassthroughRelay<Link>()
    let deleteLink = PassthroughRelay<Link>()
    let saveLink = PassthroughRelay<Link>()

  }

  // MARK: - Output

  struct Output {

    typealias SavedLinksPublisher = AnyPublisher<[Link], Never>

    let savedLinks: SavedLinksPublisher

  }

  // MARK: - Properties

  let output: Output
  let input = Input()

  private weak var cordinator: RootCoordinator?

  private let persistenceService: PersistenceService
  private let clipboardService: ClipboardService

  private let cancellable = CombineCancellable()

  // MARK: - Properties - Relays

  private let errorRelay = PassthroughRelay<Error>()
  private let savedLinksRelay = CurrentValueRelay<[Link]>([])

  // MARK: - Initialization

  init(persistenceService: PersistenceService, clipboardService: ClipboardService, cordinator: RootCoordinator) {
    self.persistenceService = persistenceService
    self.clipboardService = clipboardService
    self.cordinator = cordinator

    self.output = Output(
      savedLinks: savedLinksRelay.removeDuplicates().prepareToOutput()
    )

    bind()
  }

}

// MARK: - Private Methods

private extension LinksHistoryViewModel {

  func bind() {
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
        .sink { [weak self] link in
          self?.clipboardService.paste(link: link)
        }
      input.deleteLink
        .sink { [weak self] in self?.delete(link: $0) }
      input.saveLink
        .sink { [weak self] in self?.save(link: $0) }
      errorRelay
        .sink { [weak cordinator] in cordinator?.showAlert(for: $0) }
    }
  }

  func fetchedLinks() -> AnyPublisher<[Link], Never> {
    persistenceService.fetchLinks()
      .catch { [weak self] in self?.errorRelay.accept($0) }
      .eraseToAnyPublisher()
  }

  func delete(link: Link) {
    Task { [weak self] in
      guard let self = self else { return }
      do {
        try await self.persistenceService.delete(link: link)
      } catch {
        self.errorRelay.accept(error)
      }
    }
  }

  func save(link: Link) {
    Task { [weak self] in
      guard let self = self else { return }
      do {
        try await self.persistenceService.save(link: link)
      } catch {
        self.errorRelay.accept(error)
      }
    }
  }

}

// MARK: - Constants

private extension LinksHistoryViewModel {

  enum Constant {

    static let dataReloadDebounceTime = RunLoop.SchedulerTimeType.Stride(0.25)

  }

}
