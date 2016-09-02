import UIKit

public protocol SupplementaryViewProviding {
	func configure(supplementaryView: UICollectionReusableView,
	               ofKind: String,
	               at: IndexPath,
	               withTitle: String?)
	func reuseIdentifierForSupplementaryView(ofKind: String, at: IndexPath) -> String!
}

public struct SupplementaryViewProvider<F: UICollectionReusableView, H: UICollectionReusableView>:
	SupplementaryViewProviding where
	F: ReusableViewProtocol, H: ReusableViewProtocol, F.ViewModel == String, H.ViewModel == String {

	public init() {}

	public func configure(supplementaryView: UICollectionReusableView,
	               ofKind kind: String,
	               at _: IndexPath,
	               withTitle title: String?) {
		switch kind {
		case UICollectionElementKindSectionFooter:
			var footer = supplementaryView as! F
			footer.viewModel = title
		case UICollectionElementKindSectionHeader:
			var header = supplementaryView as! H
			header.viewModel = title
		default:
			fatalError("Unsupported supplementary view kind: \(kind)")
		}
	}

	public func reuseIdentifierForSupplementaryView(ofKind kind: String, at _: IndexPath) -> String! {
		switch kind {
		case UICollectionElementKindSectionFooter:
			return H.reuseIdentifier
		case UICollectionElementKindSectionHeader:
			return F.reuseIdentifier
		default:
			fatalError("Unsupported supplementary view kind: \(kind)")
		}
	}
}
