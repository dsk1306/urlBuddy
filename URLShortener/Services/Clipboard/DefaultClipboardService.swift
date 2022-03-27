import UIKit

final class DefaultClipboardService {}

// MARK: - ClipboardService

extension DefaultClipboardService: ClipboardService {

  func paste(link: Link) {
    UIPasteboard.general.string = link.shortenString
  }

}
