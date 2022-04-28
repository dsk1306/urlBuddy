import UIKit

final class DefaultClipboardService {}

// MARK: - ClipboardService

extension DefaultClipboardService: ClipboardService {

  var string: String? {
    UIPasteboard.general.string
  }

  func paste(link: Link) {
    UIPasteboard.general.string = link.shortenString
  }

}
