import Foundation

protocol LoggableError: LocalizedError {

  typealias AnalyticParameters = [String: Any]?
  typealias AnalyticContext = String?
  typealias AnalyticMessage = String?
  typealias ErrorCode = String?

  var analyticParameters: AnalyticParameters { get }
  var analyticContext: AnalyticContext { get }
  var analyticMessage: AnalyticMessage { get }
  var errorCode: ErrorCode { get }
  var shouldReport: Bool { get }

}

extension LoggableError {

  var analyticParameters: AnalyticParameters { nil }
  var analyticContext: AnalyticContext { nil }
  var analyticMessage: AnalyticMessage { nil }
  var errorCode: ErrorCode { nil }
  var shouldReport: Bool { true }
  var errorDescription: String? { analyticMessage }
  var localizedDescription: String { errorDescription ?? "" }

  func describing(of object: Any) -> String {
    String(describing: object)
  }

}
