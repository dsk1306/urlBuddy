import Combine
import CombineExtensions
import Foundation

class BaseViewModel {

  // MARK: - Properties

  let cancellable = CombineCancellable()

  // MARK: - Public Methods

  func bind() {}

}
