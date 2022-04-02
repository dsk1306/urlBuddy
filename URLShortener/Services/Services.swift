import Foundation

protocol Services: AnyObject, AppLifecycleSubscribableService {

  var logger: LoggerService { get }
  var clipboard: ClipboardService { get }
  var persistence: PersistenceService { get }
  var linksShortener: LinksShortenerService { get }

}
