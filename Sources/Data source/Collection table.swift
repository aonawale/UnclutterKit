import UIKit

struct CollectionTableItem {

	init<Cell: UICollectionViewCell, ViewModel>
		(_: Cell.Type,
		 viewModel: ViewModel,
		 onDidSelect: ((ViewModel, IndexPath) -> Void)? = nil)
		where Cell: ReusableViewProtocol, Cell.ViewModel == ViewModel {
			dequeueCell = { (collectionView, indexPath) in
				var cell = collectionView.dequeueReusableCell(for: indexPath) as Cell
				cell.viewModel = viewModel
				return cell
			}
			didSelectItem = {
				onDidSelect?(viewModel, $0)
			}
	}

	fileprivate let dequeueCell: (UICollectionView, IndexPath) -> UICollectionViewCell
	fileprivate let didSelectItem: (IndexPath) -> Void
}

struct CollectionTable {

	init<D: DataSourceProtocol>(
		dataSource: D,
		supplementaryViewProvider: SupplementaryViewProviding? = nil)
		where D.Item == CollectionTableItem {
			helper = CollectionViewHelper(AnyDataSource(dataSource),
			                              supplementaryViewProvider: supplementaryViewProvider)
	}

	private let helper: CollectionViewHelper

	func configure(with collectionView: UICollectionView) {
		collectionView.dataSource = helper
		collectionView.delegate = helper
	}
}

private final class CollectionViewHelper: NSObject {

	let dataSource: AnyDataSource<CollectionTableItem>
	let supplementaryViewProvider: SupplementaryViewProviding?

	init(_ dataSource: AnyDataSource<CollectionTableItem>,
	     supplementaryViewProvider: SupplementaryViewProviding?) {
		self.dataSource = dataSource
		self.supplementaryViewProvider = supplementaryViewProvider
	}
}

extension CollectionViewHelper: UICollectionViewDataSource {

	func collectionView(_ collectionView: UICollectionView,
	                    cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		return dataSource.item(at: indexPath).dequeueCell(collectionView, indexPath)
	}

	func collectionView(_ collectionView: UICollectionView,
	                    numberOfItemsInSection section: Int) -> Int {
		return dataSource.numberOfItems(inSection: section)
	}

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return dataSource.numberOfSections()
	}

	fileprivate override func responds(to aSelector: Selector!) -> Bool {
		// disable supplementary views if no provider is supplied
		if aSelector == #selector(collectionView(_:viewForSupplementaryElementOfKind:at:)) {
			return supplementaryViewProvider != nil
		}
		return super.responds(to: aSelector)
	}

	func collectionView(_ collectionView: UICollectionView,
	                    viewForSupplementaryElementOfKind kind: String,
	                    at indexPath: IndexPath) -> UICollectionReusableView {
		guard let supplementaryViewProvider = supplementaryViewProvider else {
			fatalError("\(#function) was called but no supplementaryViewProvider was supplied.")
		}

		return collectionView.dequeueReusableSupplementaryView(
			ofKind: kind,
			withReuseIdentifier: supplementaryViewProvider
				.reuseIdentifierForSupplementaryView(ofKind: kind, at: indexPath),
			for: indexPath)
			.then {
				supplementaryViewProvider.configure(
					supplementaryView: $0,
					ofKind: kind,
					at: indexPath,
					withTitle: dataSource.titleForHeader(inSection: indexPath.section))
		}
	}
}

extension CollectionViewHelper: UICollectionViewDelegate {

	fileprivate func collectionView(_ collectionView: UICollectionView,
	                            didSelectItemAt indexPath: IndexPath) {
		dataSource.item(at: indexPath).didSelectItem(indexPath)
	}
}
