import Combine
import CombineExtensions
import Foundation

/// Base class for all view models.
class BaseViewModel {

  // MARK: - Properties

  let cancellable = CombineCancellable()

  // MARK: - Public Methods

  func bind() {}

}
