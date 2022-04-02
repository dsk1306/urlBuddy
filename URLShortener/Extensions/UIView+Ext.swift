import UIKit

// MARK: - Constraints Makers

extension UIView {

  typealias ConstraintsMaker = (_ view: UIView, _ superView: UIView) -> [NSLayoutConstraint]
  typealias ArrangedSubviewConstraintsMaker = (_ view: UIView, _ stackView: UIStackView) -> [NSLayoutConstraint]

  // swiftlint:disable line_length
  /// Adds view as subview to given view, sets `translatesAutoresizingMaskIntoConstraints` to `false` and activates constraints returned in `constraintsMaker` closure.
  /// - Parameters:
  ///   - view: View we're adding to.
  ///   - constraints: The first argument is a view we're adding to. The second arguments is a view's superview. Returns an array of constraints that will be activated in superview.
  // swiftlint:enable line_length
  func add(to view: UIView, @ConstraintsBuilder constraintsMaker: ConstraintsMaker) {
    view.addSubview(self)
    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(constraintsMaker(self, view))
  }

  /// Adds view as an arranged subview to given stack view.
  /// - Parameter stackView: `UIStackView` we're adding the view to.
  func addAsArrangedSubview(to stackView: UIStackView) {
    stackView.addArrangedSubview(self)
  }

  // swiftlint:disable line_length
  /// Adds view as an arranged subview to given stack view, sets `translatesAutoresizingMaskIntoConstraints` to `false` and activates constraints returned in `constraintsMaker` closure.
  /// - Parameters:
  ///   - stackView: `UIStackView` we're adding the view to.
  ///   - constraintsMaker: The first argument is a view we're working with. The second arguments is a view's superview. Returns an array of constraints that will be activated in superview.
  // swiftlint:enable line_length
  func addAsArrangedSubview(to stackView: UIStackView, @ConstraintsBuilder constraintsMaker: ArrangedSubviewConstraintsMaker) {
    stackView.addArrangedSubview(self)
    translatesAutoresizingMaskIntoConstraints = false
    stackView.addConstraints(constraintsMaker(self, stackView))
  }

}

// MARK: - Margin Anchors

extension UIView {

  /// `layoutMarginsGuide`'s leading anchor.
  var leadingMarginAnchor: NSLayoutXAxisAnchor { layoutMarginsGuide.leadingAnchor }

  /// `layoutMarginsGuide`'s trailing anchor.
  var trailingMarginAnchor: NSLayoutXAxisAnchor { layoutMarginsGuide.trailingAnchor }

  /// `layoutMarginsGuide`'s bottom anchor.
  var bottomMarginAnchor: NSLayoutYAxisAnchor { layoutMarginsGuide.bottomAnchor }

  /// `layoutMarginsGuide`'s top anchor.
  var topMarginAnchor: NSLayoutYAxisAnchor { layoutMarginsGuide.topAnchor }

  /// `layoutMarginsGuide`'s center `y` anchor.
  var centerYMarginAnchor: NSLayoutYAxisAnchor { layoutMarginsGuide.centerYAnchor }

  /// `layoutMarginsGuide`'s center `x` anchor.
  var centerXMarginAnchor: NSLayoutXAxisAnchor { layoutMarginsGuide.centerXAnchor }

}

// MARK: - Safe Area Anchors

extension UIView {

  /// `safeAreaLayoutGuide`s leading anchor.
  var leadingSafeAnchor: NSLayoutXAxisAnchor { safeAreaLayoutGuide.leadingAnchor }

  /// `safeAreaLayoutGuide`s trailing anchor.
  var trailingSafeAnchor: NSLayoutXAxisAnchor { safeAreaLayoutGuide.trailingAnchor }

  /// `safeAreaLayoutGuide`s bottom anchor.
  var bottomSafeAnchor: NSLayoutYAxisAnchor { safeAreaLayoutGuide.bottomAnchor }

  /// `safeAreaLayoutGuide`s top anchor.
  var topSafeAnchor: NSLayoutYAxisAnchor { safeAreaLayoutGuide.topAnchor }

  /// `safeAreaLayoutGuide`s center `y` anchor.
  var centerYSafeAnchor: NSLayoutYAxisAnchor { safeAreaLayoutGuide.centerYAnchor }

  /// `safeAreaLayoutGuide`s center `x` anchor.
  var centerXSafeAnchor: NSLayoutXAxisAnchor { safeAreaLayoutGuide.centerXAnchor }

}

// MARK: - ConstraintsBuilder

extension UIView {

  @resultBuilder
  // swiftlint:disable:next convenience_type
  struct ConstraintsBuilder {

    static func buildBlock(_ content: NSLayoutConstraint...) -> [NSLayoutConstraint] { content }
    static func buildIf(_ content: NSLayoutConstraint?) -> NSLayoutConstraint? { content }
    static func buildEither(first: NSLayoutConstraint) -> NSLayoutConstraint { first }
    static func buildEither(second: NSLayoutConstraint) -> NSLayoutConstraint { second }

  }

}

// MARK: - Tune Operator

precedencegroup ForwardApplication {
  associativity: left
  higherThan: AssignmentPrecedence
}

infix operator ->>: ForwardApplication

// swiftlint:disable:next static_operator
func ->> <T>(object: T, configure: (T) -> Void) -> T {
  configure(object)
  return object
}
