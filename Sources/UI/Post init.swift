import UIKit

open class CollectionViewCell: UICollectionViewCell {
	public override init(frame: CGRect) {
		super.init(frame: frame)
		postInit()
	}

	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		postInit()
	}

	open func postInit() {}
}

open class CollectionReusableView: UICollectionReusableView {
	public override init(frame: CGRect) {
		super.init(frame: frame)
		postInit()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		postInit()
	}

	open func postInit() {}
}

open class TableViewCell: UITableViewCell {
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        postInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        postInit()
    }
    
    open func postInit() {}
}

open class ViewController: UIViewController {
    public init() {
        super.init(nibName: nil, bundle: nil)
        postInit()
    }

	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nil, bundle: nil)
		postInit()
	}

	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		postInit()
	}

	open func postInit() {}
}
