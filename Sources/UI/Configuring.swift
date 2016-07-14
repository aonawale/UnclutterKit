import UIKit

protocol Configuring {
	func configure()
}

class CollectionViewCell: UICollectionViewCell, Configuring {

	override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		configure()
	}

	func configure () {}
}

class CollectionReusableView: UICollectionReusableView, Configuring {

	override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		configure()
	}

	func configure () {}
}

class ViewController: UIViewController, Configuring {
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nil, bundle: nil)
		configure()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		configure()
	}

	func configure () {}
}
