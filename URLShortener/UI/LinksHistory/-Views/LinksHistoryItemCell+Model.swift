import Foundation

extension LinksHistory.ItemCell {

  struct Model {

    // MARK: - Properties

    let originalURL: String
    let shortenURL: String

    // MARK: - Initialization

    init(link: Link) {
      originalURL = link.originalString
      shortenURL = link.shortenString
    }

  }

}
