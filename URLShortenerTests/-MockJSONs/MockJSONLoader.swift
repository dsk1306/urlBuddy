import Foundation

enum MockJSONLoader {

  static func loadJSON(_ json: MockJSONType) throws -> Data {
    let fileName = json.fileName

    let bundle = Bundle(for: DefaultLinksShortenerServiceTests.self)
    guard let pathString = bundle.path(forResource: fileName, ofType: "json") else {
      throw JSONLoadingError.jsonPath(jsonName: fileName)
    }

    guard let jsonString = try? String(contentsOfFile: pathString, encoding: .utf8) else {
      throw JSONLoadingError.jsonString(path: pathString)
    }

    guard let jsonData = jsonString.data(using: .utf8) else {
      throw JSONLoadingError.jsonData(string: jsonString)
    }

    return jsonData
  }

}

// MARK: - JSONLoadingError

private enum JSONLoadingError: LocalizedError {

  case jsonPath(jsonName: String)
  case jsonString(path: String)
  case jsonData(string: String)

  var errorDescription: String? {
    switch self {
    case .jsonData(string: let string):
      return "Could not form data representation from json string \n \(string)"
    case .jsonPath(jsonName: let jsonName):
      return "Could not locate JSON file named \(jsonName) in bundle"
    case .jsonString(path: let path):
      return "Could not init string from file at \(path)"
    }
  }

}
