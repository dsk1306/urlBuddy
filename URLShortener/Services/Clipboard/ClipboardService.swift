import Foundation

protocol ClipboardService {

  var string: String? { get }

  func paste(link: Link)

}
