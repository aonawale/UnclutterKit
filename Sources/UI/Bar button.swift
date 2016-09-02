import UIKit

extension UIBarButtonItem: ClosureSupport {}

extension UIBarButtonItem {

	public convenience init(title: String, style: UIBarButtonItemStyle = .plain) {
		self.init(title: title, style: style, target: nil, action: nil)
	}

	public convenience init(barButtonSystemItem: UIBarButtonSystemItem) {
		self.init(barButtonSystemItem: barButtonSystemItem, target: nil, action: nil)
	}
}
