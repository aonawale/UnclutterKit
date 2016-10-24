import UIKit

public protocol Configuring {
	func configure()
}

open class CollectionViewCell: UICollectionViewCell, Configuring {
	public override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
	}

	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		configure()
	}

	open func configure() {}
}

open class CollectionReusableView: UICollectionReusableView, Configuring {
	public override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		configure()
	}

	open func configure() {}
}

open class TableViewCell: UITableViewCell, Configuring {
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    open func configure() {}
}

open class ViewController: UIViewController, Configuring {
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nil, bundle: nil)
		configure()
	}

	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		configure()
	}

	open func configure() {}
}
