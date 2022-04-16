import Combine
import CombineExtensions
import UIKit

extension LinksHistory {

  final class ViewController: BaseViewController {

    // MARK: - Typealiases

    fileprivate typealias DataSource = UICollectionViewDiffableDataSource<SectionType, Link>
    fileprivate typealias Snapshot = NSDiffableDataSourceSnapshot<SectionType, Link>

    // MARK: - Properties

    private let viewModel: ViewModel

    private let cancellable = CombineCancellable()
    private var childControllerFrameSubscription: AnyCancellable?
    private var emptyViewBottomConstraint: NSLayoutConstraint?

    private lazy var dataSource = DataSource(collectionView: collectionView) { [weak viewModel] collectionView, indexPath, item in
      let cell: ItemCell = collectionView.dequeueReusableCell(for: indexPath)
      cell.configure(with: .init(link: item))
      cell.reusableCancellable {
        cell.copy
          .sinkValue { viewModel?.input.copyLink.accept(item) }
        cell.delete
          .sinkValue { viewModel?.input.deleteLink.accept(item) }
      }
      return cell
    }

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: Self.layout())

    // MARK: - Properties - Subviews

    private lazy var emptyView = EmptyView()

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

      view.backgroundColor = .systemBackground

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
          .map { $0.isEmpty }
          .removeDuplicates()
          .sinkValue { [weak self] isEmpty in
            self?.navigationItem.titleView = isEmpty ? nil : self?.titleView
            self?.configureEmptyView(isEmpty: isEmpty)
          }
      }
    }

    override func addChild(_ childController: UIViewController) {
      super.addChild(childController)

      // TODO: Maybe move it somewhere else.
      childController.view.add(to: view) {
        $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
        $1.trailingAnchor.constraint(equalTo: $0.trailingAnchor)
        $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
      }

      childControllerFrameSubscription = childController.view.publisher(for: \.bounds)
        .map { [weak self] bounds -> CGFloat in
          guard let self = self else { return bounds.height }
          return bounds.height - self.collectionView.safeAreaInsets.bottom
        }
        .removeDuplicates()
        .sinkValue { [weak self] inset in
          guard let self = self else { return }
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
