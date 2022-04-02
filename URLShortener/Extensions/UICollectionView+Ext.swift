import UIKit

extension UICollectionView {

  // swiftlint:disable line_length
  /// Returns a reusable cell object located by its identifier.
  /// - Parameter indexPath: The index path specifying the location of the cell. The data source receives this information when it is asked for the cell and should just pass it along. This method uses the index path to perform additional configuration based on the cell’s position in the collection view.
  // swiftlint:enable line_length
  func dequeueReusableCell<Cell: UICollectionViewCell>(for indexPath: IndexPath) -> Cell {
    let identifier = String(describing: Cell.self)
    guard let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? Cell else {
      fatalError("Could not dequeue cell named \(identifier)")
    }
    return cell
  }

  /// Register a class for use in creating new collection view cells.
  /// - Parameter cellClass: The class of a cell that you want to use in the collection view.
  func register<Cell: UICollectionViewCell>(cellClass: Cell.Type) {
    let identifier = String(describing: Cell.self)
    register(Cell.self, forCellWithReuseIdentifier: identifier)
  }

  /// Register a nib file for use in creating new collection view cells.
  /// - Parameters:
  ///   - class: The class of the cell contained in the nib object. The nib and the class must have the same name.
  ///   - bundle: The bundle in which to search for the nib file. If you specify `nil`, this method looks for the nib file in the main bundle.
  func register<Cell: UICollectionViewCell>(cellNibWithClass class: Cell.Type, bundle: Bundle? = nil) {
    let identifier = String(describing: Cell.self)
    let nib = UINib(nibName: identifier, bundle: bundle)
    register(nib, forCellWithReuseIdentifier: identifier)
  }

  /// Registers a class for use in creating supplementary views for the collection view.
  /// - Parameters:
  ///   - viewClass: The class to use for the supplementary view.
  ///   - kind: The kind of supplementary view to create. This value is defined by the layout object.
  func register<ReusableView: UICollectionReusableView>(viewClass: ReusableView.Type, forKind kind: ReusableSupplementaryViewKind) {
    let identifier = String(describing: ReusableView.self)
    register(ReusableView.self, forSupplementaryViewOfKind: kind.rawValue, withReuseIdentifier: identifier)
  }

  /// Registers a nib file for use in creating supplementary views for the collection view.
  /// - Parameters:
  ///   - class: The class of the reusable view contained in the nib object. The nib and the class must have the same name.
  ///   - kind: The kind of supplementary view to create. This value is defined by the layout object.
  ///   - bundle: The bundle in which to search for the nib file. If you specify `nil`, this method looks for the nib file in the main bundle.
  // swiftlint:disable:next line_length
  func register<ReusableView: UICollectionReusableView>(cellNibWithReusableViewClass class: ReusableView.Type, forKind kind: ReusableSupplementaryViewKind, bundle: Bundle? = nil) {
    let identifier = String(describing: ReusableView.self)
    let nib = UINib(nibName: identifier, bundle: bundle)
    register(nib, forSupplementaryViewOfKind: kind.rawValue, withReuseIdentifier: identifier)
  }

  // swiftlint:disable line_length
  /// Returns a reusable supplementary view located by its identifier and kind.
  /// - Parameters:
  ///   - kind: The kind of supplementary view to retrieve. This value is defined by the layout object.
  ///   - indexPath: The index path specifying the location of the supplementary view in the collection view. The data source receives this information when it is asked for the view and should just pass it along. This method uses the information to perform additional configuration based on the view’s position in the collection view.
  /// - Returns: A valid UICollectionReusableView object.
  // swiftlint:enable line_length
  // swiftlint:disable:next line_length
  func dequeueReusableSupplementaryView<ReusableView: UICollectionReusableView>(ofKind kind: ReusableSupplementaryViewKind, for indexPath: IndexPath) throws -> ReusableView {
    let identifier = String(describing: ReusableView.self)
    guard let view = dequeueReusableSupplementaryView(ofKind: kind.rawValue, withReuseIdentifier: identifier, for: indexPath) as? ReusableView else {
      fatalError("Could not dequeue supplementary view named \(identifier)")
    }
    return view
  }

}

// MARK: - ReusableSupplementaryViewKind

extension UICollectionView {

  enum ReusableSupplementaryViewKind {

    case header
    case footer

    internal var rawValue: String {
      switch self {
      case .footer:
        return UICollectionView.elementKindSectionFooter
      case .header:
        return UICollectionView.elementKindSectionHeader
      }
    }

  }

}
