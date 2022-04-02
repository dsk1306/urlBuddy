// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen
import UIKit

// swiftlint:disable all
enum ColorAsset {

  static var athensGray: UIColor { Asset(name: "athensGray").color }
  static var martinique: UIColor { Asset(name: "martinique").color }
  static var tuna: UIColor { Asset(name: "tuna").color }
  static var turquoise: UIColor { Asset(name: "turquoise").color }
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
