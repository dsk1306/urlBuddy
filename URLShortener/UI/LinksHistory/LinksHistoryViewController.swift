import Combine
import CombineExtensions
import UIKit

final class LinksHistoryViewController: UIViewController {

  // MARK: - Typealiases

  fileprivate typealias DataSource = UICollectionViewDiffableDataSource<SectionType, Link>
  fileprivate typealias Snapshot = NSDiffableDataSourceSnapshot<SectionType, Link>

  // MARK: - Properties

  private let viewModel: LinksHistoryViewModel

  private let cancellable = CombineCancellable()
  private var childControllerFrameSubscription: AnyCancellable?
  private var emptyViewBottomConstraint: NSLayoutConstraint?

  private lazy var dataSource = DataSource(collectionView: collectionView) { [weak viewModel] collectionView, indexPath, item in
    let cell: LinksHistoryItemCell = collectionView.dequeueReusableCell(for: indexPath)
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

  private lazy var emptyView = LinksHistoryEmptyView()

  private lazy var titleView = UILabel() ->> { titleView in
    titleView.text = LocalizedString.LinksHistory.yourHistory
    titleView.textColor = ColorAsset.tuna
  }

  // MARK: - Initialization

  init(viewModel: LinksHistoryViewModel) {
    self.viewModel = viewModel

    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Base Class

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    collectionView.add(to: view) { collectionView, view in
      collectionView.leadingAnchor.constraint(equalTo: view.leadingSafeAnchor)
      collectionView.topAnchor.constraint(equalTo: view.topSafeAnchor)
      view.trailingSafeAnchor.constraint(equalTo: collectionView.trailingAnchor)
      view.bottomSafeAnchor.constraint(equalTo: collectionView.bottomAnchor)
    }

    configureTitleView()
    configureCollectionView()
    bind()
  }

  override func addChild(_ childController: UIViewController) {
    super.addChild(childController)

    // TODO: Maybe move it somewhere else.
    childController.view.add(to: view) { childControllerView, view in
      childControllerView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
      view.trailingAnchor.constraint(equalTo: childControllerView.trailingAnchor)
      childControllerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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

// MARK: - Private Methods

private extension LinksHistoryViewController {

  static func snapshot(with savedLinks: [Link]) -> Snapshot {
    var snapShot = Snapshot()

    for link in savedLinks {
      let section = SectionType.link(link)
      snapShot.appendSections([section])
      snapShot.appendItems([link], toSection: section)
    }

    return snapShot
  }

  func configureCollectionView() {
    collectionView.register(cellClass: LinksHistoryItemCell.self)
  }

  func configureTitleView() {
    let titleView = UILabel() ->> { titleView in
      titleView.text = LocalizedString.LinksHistory.yourHistory
      titleView.textColor = ColorAsset.tuna
    }
    navigationItem.titleView = titleView
  }

}

// MARK: - Private Methods - Binding

private extension LinksHistoryViewController {

  func bind() {
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

  func configureEmptyView(isEmpty: Bool) {
    if collectionView.backgroundView == nil {
      collectionView.backgroundView = UIView()
    }

    if isEmpty, let backgroundView = collectionView.backgroundView {
      emptyView.add(to: backgroundView) { emptyView, backgroundView in
        emptyView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor)
        emptyView.topAnchor.constraint(equalTo: backgroundView.topAnchor)
        backgroundView.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor)
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

private extension LinksHistoryViewController {

  static func layout() -> UICollectionViewLayout {
    UICollectionViewCompositionalLayout.list(
      using: UICollectionLayoutListConfiguration(appearance: .insetGrouped)
    )
  }

}

// MARK: - SectionType

private extension LinksHistoryViewController {

  enum SectionType: Hashable {
    case link(Link)
  }

}
