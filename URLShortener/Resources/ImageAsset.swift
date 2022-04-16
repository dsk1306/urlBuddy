// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen
import UIKit

// swiftlint:disable all
enum ImageAsset {

  static var background: UIImage { Asset(name: "background").image }
  static var logo: UIImage { Asset(name: "logo").image }

  static var onError: ((Error) -> Void)?

}
// swiftlint:enable all

// MARK: - Image Asset

private extension ImageAsset {

  struct Asset {

    let name: String

    var image: UIImage {
      guard let result = UIImage(named: name) else {
        ImageAsset.onError?(InitError.imageInit(name: name))
        return UIImage()
      }
      return result
    }

  }

}

// MARK: - InitError

extension ImageAsset {

  enum InitError: Error {

    case imageInit(name: String)
    case sfSymbolInit(name: String)

  }

}
