import Combine
import CombineExtensions
import Foundation
import Logger

/// Base class for all view models.
class BaseViewModel {

  // MARK: - Properties

  let cancellable = CombineCancellable()

  private(set) weak var cordinator: RootCoordinator?

  private(set) lazy var errorHandler: AppLifecycleSubscribableService.ErrorHandler = { [weak self] in
    self?.log(error: $0)
  }

  private let logger: LoggerService

  // MARK: - Initialization

  init(services: Services, cordinator: RootCoordinator) {
    self.logger = services.logger
    self.cordinator = cordinator
  }

  // MARK: - Public Methods

  func bind() {}

  func log(error: Error) {
    logger.log(error: error)
  }

}
