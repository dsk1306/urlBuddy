import Foundation

enum LocalizedString {}

// MARK: - Empty View

extension LocalizedString {

  enum EmptyView {

    /// Localized string with a key equal to `emptyView::getStartedTitle`
    /// and value equal to `Let’s get started!`.
    static var title: String {
      NSLocalizedString(
        "emptyView::getStartedTitle",
        value: "Let’s get started!",
        comment: "Title of links history empty view."
      )
    }

    /// Localized string with a key equal to `emptyView::getStartedMessage`
    /// and value equal to `Paste your first link into the field to shorten it`.
    static var message: String {
      NSLocalizedString(
        "emptyView::getStartedMessage",
        value: "Paste your first link into the field to shorten it",
        comment: "Caption of links history empty view."
      )
    }

  }

}

// MARK: - LinksHistory

extension LocalizedString {

  enum LinksHistory {

    /// Localized string with a key equal to `linksHistory::yourHistory`
    /// and value equal to `Your Link History`.
    static var yourHistory: String {
      NSLocalizedString(
        "linksHistory::yourHistory",
        value: "Your Link History",
        comment: "Title of links history header"
      )
    }

    /// Localized string with a key equal to `linksHistory::copy`
    /// and value equal to `Copy`.
    static var copy: String {
      NSLocalizedString(
        "linksHistory::copy",
        value: "Copy",
        comment: "Title of copy CTA button."
      )
    }

    /// Localized string with a key equal to `linksHistory::copied`
    /// and value equal to `Copied!`.
    static var copied: String {
      NSLocalizedString(
        "linksHistory::copied",
        value: "Copied!",
        comment: "Title of copy CTA button after successful copy."
      )
    }

  }

}

// MARK: - LinkShortener

extension LocalizedString {

  enum LinkShortener {

    /// Localized string with a key equal to `linkShortener::cta`
    /// and value equal to `Shorten it!`.
    static var cta: String {
      NSLocalizedString(
        "linkShortener::cta",
        value: "Shorten it!",
        comment: "Title of shortener CTA button."
      )
    }

    /// Localized string with a key equal to `linkShortener::placeholder`
    /// and value equal to `Shorten a link here ...`.
    static var placeholder: String {
      NSLocalizedString(
        "linkShortener::placeholder",
        value: "Shorten a link here ...",
        comment: "Placeholder of shortener text field."
      )
    }

    /// Localized string with a key equal to `linkShortener::emptyLinkError`
    /// and value equal to `Please add a link here`.
    static var emptyLinkError: String {
      NSLocalizedString(
        "linkShortener::emptyLinkError",
        value: "Please add a link here",
        comment: "Text for empty link error."
      )
    }

  }

}

// MARK: - ErrorAlert

extension LocalizedString {

  enum ErrorAlert {

    /// Localized string with a key equal to `errorAlert::title`
    /// and value equal to `Oops`.
    static var title: String {
      NSLocalizedString(
        "errorAlert::title",
        value: "Oops",
        comment: "Title of generic error alert."
      )
    }

    /// Localized string with a key equal to `errorAlert::okAction`
    /// and value equal to `OK`.
    static var okAction: String {
      NSLocalizedString(
        "errorAlert::okAction",
        value: "OK",
        comment: "Title of close alert button."
      )
    }

  }

}
