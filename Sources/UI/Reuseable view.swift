import UIKit

protocol ReusableViewProtocol {
	associatedtype ViewModel
	var viewModel: ViewModel? { get set }
}

extension ReusableViewProtocol where Self: UIView {

	static var reuseIdentifier: String {
		return String(self)
	}
}

extension UITableView {

	func dequeueReusableCell<T: UITableViewCell where T: ReusableViewProtocol>(for indexPath: IndexPath) -> T {
		guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
			fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
		}
		return cell
	}

	func register<T: UITableViewCell where T: ReusableViewProtocol>(_: T.Type) {
		register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
	}
}

extension UICollectionView {

	func dequeueReusableCell<T: UICollectionViewCell where T: ReusableViewProtocol>(for indexPath: IndexPath) -> T {
		guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
			fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
		}
		return cell
	}

	func register<T: UICollectionViewCell where T: ReusableViewProtocol>(_: T.Type) {
		register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
	}

	func registerFooterView<T: UICollectionReusableView where T: ReusableViewProtocol>(_: T.Type) {
		register(T.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: T.reuseIdentifier)
	}

	func registerHeaderView<T: UICollectionReusableView where T: ReusableViewProtocol>(_: T.Type) {
		register(T.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: T.reuseIdentifier)
	}
}
