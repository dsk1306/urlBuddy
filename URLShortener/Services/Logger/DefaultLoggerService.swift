import Bugsnag
import Foundation

final class DefaultLoggerService {

  // MARK: - Properties

  var onOptOut: OnOptOutHandler?

  // MARK: - Initialization

  init(onOptOut: OnOptOutHandler?) {
    self.onOptOut = onOptOut
  }

}

// MARK: - Private Methods

private extension DefaultLoggerService {

  static func writeParameters(from error: LoggableError, to report: BugsnagEvent) {
    guard let parameters = error.analyticParameters else { return }
    for (key, value) in parameters {
      report.addMetadata(value, key: key, section: Constant.sectionName)
    }
  }

  static func writeContext(from error: LoggableError, to report: BugsnagEvent) {
    guard let context = error.analyticContext else { return }
    report.context = context
  }

  static func writeErrorClass(from error: LoggableError, to report: BugsnagEvent) {
    for reportError in report.errors {
      reportError.errorClass = "\(type(of: error))"
    }
  }

  static func writeErrorMessage(from error: LoggableError, to report: BugsnagEvent) {
    for reportError in report.errors {
      reportError.errorMessage = error.analyticMessage
    }
  }

  /// Calls `print` function if build configuration is set to `DEBUG`.
  ///
  /// - Parameter items: Zero or more items to print.
  func printInDebug(items: Any...) {
    #if DEBUG
    print(items)
    #endif
  }

}

// MARK: - AppLifecycleSubscribableService

extension DefaultLoggerService: AppLifecycleSubscribableService {

  func handleConnectToScene(with connectionOptions: ConnectionOptions, onError: @escaping ErrorHandler) {
    let configuration = BugsnagConfiguration(Constant.apiKey)
    configuration.addOnSendError { [weak self] _ in
      // Prevent logging if opt-out.
      if self?.onOptOut?() == true { return false }
      // Otherwise report error.
      return true
    }

    #if DEBUG
    configuration.releaseStage = Constant.developmentStage
    #else
    configuration.releaseStage = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
      ? Constant.testFlightStage
      : Constant.productionStage
    #endif

    Bugsnag.start(with: configuration)
  }

}

// MARK: - LoggerService

extension DefaultLoggerService: LoggerService {

  func log(error: String) {
    let error = StringError(errorString: error)
    log(error: error)
  }

  func log(error: Error) {
    if let error = error as? LoggableError {
      guard error.shouldReport else { return }
      Bugsnag.notifyError(error) { report in
        Self.writeErrorClass(from: error, to: report)
        Self.writeParameters(from: error, to: report)
        Self.writeContext(from: error, to: report)
        Self.writeErrorMessage(from: error, to: report)
        return true
      }
    } else {
      Bugsnag.notifyError(error)
    }
  }

  func log(deinitOf object: Any) {
    let typeOfObject = type(of: object)
    let describing = String(describing: typeOfObject)
    printInDebug(items: "\(describing) was deinited")
  }

  func log(items: Any...) {
    printInDebug(items: items)
  }

}

// MARK: - Constants

private extension DefaultLoggerService {

  enum Constant {

    static let sectionName = "UserInfo"

    static let testFlightStage = "TestFlight"
    static let developmentStage = "Development"
    static let productionStage = "Production"

    static let apiKey = "e24bffe1629ee22a401c574d29a98d2f"

  }

}

// MARK: - String Error

extension DefaultLoggerService {

  struct StringError: LoggableError {

    let errorString: String?

    var analyticMessage: AnalyticMessage { errorString }

  }

}
