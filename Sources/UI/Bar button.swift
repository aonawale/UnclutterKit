import UIKit

extension UIBarButtonItem: ClosureSupport {}

extension UIBarButtonItem {

	convenience init(title: String, style: UIBarButtonItemStyle = .plain) {
		self.init(title: title, style: style, target: nil, action: nil)
	}

	convenience init(barButtonSystemItem: UIBarButtonSystemItem) {
		self.init(barButtonSystemItem: barButtonSystemItem, target: nil, action: nil)
	}
}
