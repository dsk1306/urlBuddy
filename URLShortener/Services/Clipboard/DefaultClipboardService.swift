import UIKit

final class DefaultClipboardService {

  // MARK: - Properties

  private let pasteboard = UIPasteboard.general

}

// MARK: - ClipboardService

extension DefaultClipboardService: ClipboardService {

  var string: String? {
    guard pasteboard.hasStrings else { return nil }
    return pasteboard.string
  }

  func paste(link: Link) {
    pasteboard.string = link.shortenString
  }

}
