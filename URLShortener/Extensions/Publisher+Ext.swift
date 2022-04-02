import Combine
import Foundation

extension Publisher {

  /// Erases publisher and send it output on main queue.
  func prepareToOutput() -> AnyPublisher<Output, Failure> {
    self.receive(on: DispatchQueue.main).eraseToAnyPublisher()
  }

  func `catch`(errorHandler: @escaping (Error) -> Void) -> AnyPublisher<Output, Never> {
    // swiftlint:disable:next trailing_closure
    map { value -> Output? in value }
      .handleEvents(receiveCompletion: { completion in
        switch completion {
        case .failure(let error):
          errorHandler(error)

        case .finished:
          break
        }
      })
      .catch { _ in Just(nil) }
      .compactMap { $0 }
      .eraseToAnyPublisher()
  }

}
