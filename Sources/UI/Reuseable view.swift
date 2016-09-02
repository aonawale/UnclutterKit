import UIKit

protocol ReusableViewProtocol {
	associatedtype ViewModel
	var viewModel: ViewModel? { get set }
}

extension ReusableViewProtocol where Self: UIView {

	static var reuseIdentifier: String {
		return String(describing: self)
	}
}

extension UITableView {

	func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T
		where T: ReusableViewProtocol {
			guard let cell = dequeueReusableCell(
				withIdentifier: T.reuseIdentifier,
				for: indexPath) as? T else {
					fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
			}
			return cell
	}

	func register<T: UITableViewCell>(_: T.Type) where T: ReusableViewProtocol {
		register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
	}
}

extension UICollectionView {

	func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T
		where T: ReusableViewProtocol {
			guard let cell = dequeueReusableCell(
				withReuseIdentifier: T.reuseIdentifier,
				for: indexPath) as? T else {
					fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
			}
			return cell
	}

	func register<T: UICollectionViewCell>(_: T.Type) where T: ReusableViewProtocol {
		register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
	}

	func registerFooterView<T: UICollectionReusableView>(_: T.Type) where T: ReusableViewProtocol {
		register(T.self,
		         forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
		         withReuseIdentifier: T.reuseIdentifier)
	}

	func registerHeaderView<T: UICollectionReusableView>(_: T.Type) where T: ReusableViewProtocol {
		register(T.self,
		         forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
		         withReuseIdentifier: T.reuseIdentifier)
	}
}
