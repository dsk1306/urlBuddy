// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen
import UIKit

// swiftlint:disable all
enum ColorAsset {

  static var martinique: UIColor { Asset(name: "martinique").color }
  static var roman: UIColor { Asset(name: "roman").color }
  static var tuna: UIColor { Asset(name: "tuna").color }
  static var сarnation: UIColor { Asset(name: "сarnation").color }

  static var onError: ((Error) -> Void)?

}
// swiftlint:enable all

// MARK: - Color Asset

private extension ColorAsset {

  struct Asset {

    let name: String

    var color: UIColor {
      guard let result = UIColor(named: name) else {
        ColorAsset.onError?(InitError.colorInit(name: name))
        return .clear
      }
      return result
    }

  }

}

// MARK: - InitError

private extension ColorAsset {

  enum InitError: Error {

    case colorInit(name: String)

  }

}
