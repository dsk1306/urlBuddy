import Combine
import UIKit

extension NotificationCenter {

  var keyboardPublisher: AnyPublisher<KeyboardPublisherOutput, Never> {
    let keyboardWillShow = publisher(for: UIWindow.keyboardWillShowNotification)
      .map { $0.userInfo ?? [:] }
      .map { userInfo in
        KeyboardPublisherOutput(
          frameHeight: Self.keyboardFrameHeight(from: userInfo),
          animationDuration: Self.keyboardAnimationDuration(from: userInfo),
          animationOptions: Self.keyboardAnimationOptions(from: userInfo)
        )
      }
    let keyboardWillHide = publisher(for: UIWindow.keyboardWillHideNotification)
      .map { $0.userInfo ?? [:] }
      .map { userInfo in
        KeyboardPublisherOutput(
          frameHeight: 0,
          animationDuration: Self.keyboardAnimationDuration(from: userInfo),
          animationOptions: Self.keyboardAnimationOptions(from: userInfo)
        )
      }

    return Publishers.Merge(keyboardWillShow, keyboardWillHide)
      .eraseToAnyPublisher()
  }

}

// MARK: - Helpers

private extension NotificationCenter {

  typealias UserInfo = [AnyHashable: Any]

  static func keyboardFrameHeight(from userInfo: UserInfo) -> CGFloat {
    guard let keyboardFrameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
      return 0
    }
    return keyboardFrameEnd.height
  }

  static func keyboardAnimationDuration(from userInfo: UserInfo) -> TimeInterval {
    guard let number = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
      return 0.5
    }
    return number
  }

  static func keyboardAnimationOptions(from userInfo: UserInfo) -> UIView.AnimationOptions {
    guard let number = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
      return .curveEaseIn
    }
    return UIView.AnimationOptions(rawValue: number)
  }

}

// MARK: - KeyboardPublisherOutput

extension NotificationCenter {

  struct KeyboardPublisherOutput {

    let frameHeight: CGFloat
    let animationDuration: TimeInterval
    let animationOptions: UIView.AnimationOptions

  }

}
