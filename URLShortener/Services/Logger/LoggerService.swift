import Foundation

protocol LoggerService: AnyObject, AppLifecycleSubscribableService {

  typealias OnOptOutHandler = () -> Bool

  var onOptOut: OnOptOutHandler? { get set }

  func log(error: String)
  func log(error: Error)
  func log(deinitOf object: Any)
  func log(items: Any...)

}
