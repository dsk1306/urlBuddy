import Combine
import CombineExtensions
import UIKit
import UIKitExtensions

extension LinksHistory {

  final class ViewController: BaseViewController {

    // MARK: - Typealiases

    fileprivate typealias DataSource = UICollectionViewDiffableDataSource<SectionType, Link>
    fileprivate typealias Snapshot = NSDiffableDataSourceSnapshot<SectionType, Link>

    // MARK: - Properties

    private let viewModel: ViewModel

    private let cancellable = CombineCancellable()
    private var childControllerFrameSubscription: AnyCancellable?

    private lazy var dataSource = DataSource(collectionView: collectionView) { [weak viewModel] collectionView, indexPath, item in
      let cell: ItemCell = collectionView.dequeueReusableCell(for: indexPath)
      cell.configure(with: .init(link: item))
      cell.reusableCancellable {
        cell.copy.sinkValue { viewModel?.input.copyLink.accept(item) }
        cell.delete.sinkValue { viewModel?.input.deleteLink.accept(item) }
        cell.shortenedLinkTap.sinkValue { viewModel?.input.openLink.accept(item.shorten) }
      }
      return cell
    }

    // MARK: - Properties - Constraints

    private var emptyViewBottomConstraint: NSLayoutConstraint?
    private var shortenerViewBottomConstraint: NSLayoutConstraint?

    // MARK: - Properties - Subviews

    private lazy var emptyView = EmptyView()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: Self.layout())

    private lazy var titleView = UILabel() ->> {
      $0.text = LocalizedString.LinksHistory.yourHistory
      $0.textColor = ColorAsset.tuna
    }

    // MARK: - Initialization

    init(viewModel: ViewModel) {
      self.viewModel = viewModel

      super.init()
    }

    // MARK: - Base Class

    override func configureSubviews() {
      super.configureSubviews()

      view.backgroundColor = .systemGroupedBackground
      collectionView.backgroundColor = view.backgroundColor

      // Collection View.
      collectionView.register(cellClass: ItemCell.self)

      collectionView.add(to: view) {
        $0.leadingAnchor.constraint(equalTo: $1.leadingSafeAnchor)
        $0.topAnchor.constraint(equalTo: $1.topSafeAnchor)
        $1.trailingSafeAnchor.constraint(equalTo: $0.trailingAnchor)
        $1.bottomSafeAnchor.constraint(equalTo: $0.bottomAnchor)
      }
    }

    override func bind() {
      super.bind()

      viewModel.bind()

      cancellable {
        viewModel.output.savedLinks
          .map(Self.snapshot)
          .sinkValue { [weak dataSource] in dataSource?.apply($0) }
        viewModel.output.savedLinks
          .map(\.isEmpty)
          .removeDuplicates()
          .sinkValue { [weak self] isEmpty in
            self?.navigationItem.titleView = isEmpty ? nil : self?.titleView
            self?.configureEmptyView(isEmpty: isEmpty)
          }
        NotificationCenter.default.keyboardPublisher
          .receive(on: DispatchQueue.main)
          .sinkValue { [weak self] in
            self?.updateShortenerViewBottomConstraint(with: $0)
          }
        NotificationCenter.default.keyboardPublisher
          .map { $0.frameHeight == 0 ? 1 : 0 }
          .removeDuplicates()
          .assign(to: \.alpha, on: collectionView, ownership: .weak)
      }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesBegan(touches, with: event)

      view.endEditing(true)
    }

    override func addChild(_ childController: UIViewController) {
      super.addChild(childController)

      let childControllerBottomConstraint = view.bottomAnchor.constraint(equalTo: childController.view.bottomAnchor)
      shortenerViewBottomConstraint = childControllerBottomConstraint

      // TODO: Maybe move it somewhere else.
      childController.view.add(to: view) {
        $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
        $1.trailingAnchor.constraint(equalTo: $0.trailingAnchor)
        childControllerBottomConstraint
      }

      childControllerFrameSubscription = childController.view.publisher(for: \.bounds)
        .map(\.height)
        .removeDuplicates()
        .sinkValue { [weak self] inset in
          guard let self else { return }
          self.collectionView.contentInset.bottom = inset
          self.collectionView.verticalScrollIndicatorInsets.bottom = inset
          self.emptyViewBottomConstraint?.constant = inset
          self.view.layoutIfNeeded()
        }
    }

  }

}

// MARK: - Private Methods

private extension LinksHistory.ViewController {

  static func snapshot(with savedLinks: [Link]) -> Snapshot {
    var snapShot = Snapshot()

    for link in savedLinks {
      let section = SectionType.link(link)
      snapShot.appendSections([section])
      snapShot.appendItems([link], toSection: section)
    }

    return snapShot
  }

  func configureEmptyView(isEmpty: Bool) {
    if collectionView.backgroundView == nil {
      collectionView.backgroundView = UIView()
    }

    if isEmpty, let backgroundView = collectionView.backgroundView {
      emptyView.add(to: backgroundView) {
        $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
        $0.topAnchor.constraint(equalTo: $1.topAnchor)
        $1.trailingAnchor.constraint(equalTo: $0.trailingAnchor)
      }

      emptyViewBottomConstraint = backgroundView.bottomAnchor.constraint(
        equalTo: emptyView.bottomAnchor,
        constant: collectionView.contentInset.bottom
      )
      emptyViewBottomConstraint?.isActive = true
    } else {
      emptyView.removeFromSuperview()
    }
  }

  func updateShortenerViewBottomConstraint(with output: NotificationCenter.KeyboardPublisherOutput) {
    UIView.animate(withDuration: output.animationDuration, delay: 0, options: output.animationOptions) { [weak self] in
      guard let self else { return }
      self.shortenerViewBottomConstraint?.constant = output.frameHeight
      self.view?.layoutIfNeeded()
    }
  }

}

// MARK: - Private Methods - Layout

private extension LinksHistory.ViewController {

  static func layout() -> UICollectionViewLayout {
    UICollectionViewCompositionalLayout.list(
      using: UICollectionLayoutListConfiguration(appearance: .insetGrouped)
    )
  }

}

// MARK: - SectionType

private extension LinksHistory.ViewController {

  enum SectionType: Hashable {
    case link(Link)
  }

}
