import UIKit

extension ImageAsset {

  static var delete: UIImage { SFSymbol(name: "trash.fill").image }

}

// MARK: - SF Symbol

private extension ImageAsset {

  struct SFSymbol {

    let name: String

    var image: UIImage {
      guard let result = UIImage(systemName: name) else {
        ImageAsset.onError?(InitError.sfSymbolInit(name: name))
        return UIImage()
      }
      return result
    }

  }

}
