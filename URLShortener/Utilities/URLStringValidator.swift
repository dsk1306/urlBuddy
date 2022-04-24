import Foundation

struct URLStringValidator {

  // MARK: - Properties

  let urlString: String
  let isValid: Bool

  // MARK: - Initialization

  init(urlString: String) throws {
    self.urlString = urlString
    self.isValid = try Self.isStringURLValid(urlString)
  }

}

// MARK: - Private Methods

private extension URLStringValidator {

  static func isStringURLValid(_ string: String) throws -> Bool {
    guard !string.isEmpty else { return false }

    let type = NSTextCheckingResult.CheckingType.link
    let detector = try NSDataDetector(types: type.rawValue)
    let options = NSRegularExpression.MatchingOptions(rawValue: 0)
    let range = NSRange(0..<string.count)
    return detector.numberOfMatches(in: string, options: options, range: range) > 0
  }

}
