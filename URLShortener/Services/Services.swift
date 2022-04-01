import Foundation

protocol Services: AnyObject, AppLifecycleSubscribableService {

  var logger: LoggerService { get }

}
